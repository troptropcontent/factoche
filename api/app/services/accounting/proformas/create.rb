module Accounting
  module Proformas
    class Create
    include ApplicationService

      # Acceptable tolerance for financial calculations (in cents)
      # to account for floating-point precision errors
      AMOUNT_TOLERANCE = 0.01

       class Contract < Dry::Validation::Contract
          params do
            required(:company).hash(CompanySchema)
            required(:client).hash(ClientSchema)
            required(:project_version).hash(ProjectVersionSchema)
            required(:project).hash(ProjectSchema)
            required(:snapshot_number).filled(:integer)
            required(:new_invoice_items).array(:hash) do
              required(:original_item_uuid).filled(:string)
              required(:invoice_amount).filled(:decimal)
            end
            optional(:issue_date).filled(:time)
          end
       end

      def call(args)
        validated_args = validate!(args, Contract)
        company = validated_args[:company]
        client = validated_args[:client]
        project = validated_args[:project]
        project_version = validated_args[:project_version]
        snapshot_number = validated_args[:snapshot_number]
        new_invoice_items = validated_args[:new_invoice_items]
        issue_date = validated_args[:issue_date] || Time.current

        proforma = ActiveRecord::Base.transaction do
          # Create a proforma record
          base_proforma_attributes = build_proforma_attributes!(company.fetch(:id), client.fetch(:id), project, project_version, new_invoice_items, snapshot_number, issue_date)

          financial_year = find_financial_year!(issue_date, company.fetch(:id))
          proforma_number = find_next_available_proforma_number!(company.fetch(:id), financial_year.id, issue_date)
          proforma = Proforma.create!(base_proforma_attributes.merge({ number: proforma_number, financial_year:  financial_year }))

          # Create proforma line records
          proforma_lines_attributes = build_proforma_lines_attributes!(proforma.context, new_invoice_items)
          proforma.lines.create!(proforma_lines_attributes)

          # Create proforma details records
          proforma_detail_attributes = build_proforma_detail_attributes!(company, client, project, project_version, issue_date)
          proforma.create_detail!(proforma_detail_attributes)

          # Verify that totals recorded in draft_invoice are in line with its lines as this is crucial, better be safe than sorry
          ensure_totals_are_correct!(proforma)

          proforma
        end

        FinancialTransactions::GenerateAndAttachPdfJob.perform_async({ "financial_transaction_id" => proforma.id })

        proforma
      end

      private

      def find_financial_year!(issue_date, company_id)
        result = FinancialYears::FindFromDate.call(company_id, issue_date)

        raise result.error if result.failure?
        result.data
      end

      def build_proforma_attributes!(company_id, client_id, project, project_version, new_invoice_items, snapshot_number, issue_date)
        result = BuildAttributes.call({
          company_id:,
          client_id:,
          project:,
          project_version:,
          new_invoice_items:,
          issue_date:,
          snapshot_number:
        })

        raise result.error if result.failure?
        result.data
      end

      def build_proforma_lines_attributes!(proforma_context, proforma_items)
        result = BuildLinesAttributes.call(proforma_context, proforma_items)

        raise result.error if result.failure?
        result.data
      end

      def build_proforma_detail_attributes!(company, client, project, project_version, issue_date)
        result = BuildDetailAttributes.call({ company:, client:, project:, project_version:, issue_date: })

        raise result.error if result.failure?
        result.data
      end

      def find_next_available_proforma_number!(company_id, financial_year_id, issue_date)
        result = FinancialTransactions::FindNextAvailableNumber.call(company_id: company_id, prefix: Proforma::NUMBER_PREFIX, financial_year_id: financial_year_id, issue_date: issue_date)

        raise result.error if result.failure?
        result.data
      end

      def ensure_totals_are_correct!(draft_invoice)
        expected_total_excl_tax_amount = draft_invoice.lines.sum("quantity * unit_price_amount")
        unless (expected_total_excl_tax_amount - draft_invoice.total_excl_tax_amount).abs < AMOUNT_TOLERANCE
          raise Error::UnprocessableEntityError, "Total excluding tax amount mismatch: expected #{expected_total_excl_tax_amount}, got #{draft_invoice.total_excl_tax_amount}"
        end

        expected_total_including_tax_amount = draft_invoice.lines.sum("quantity * unit_price_amount * (1 + tax_rate)")
        unless (draft_invoice.total_including_tax_amount - expected_total_including_tax_amount).abs < AMOUNT_TOLERANCE
          raise Error::UnprocessableEntityError, "Total including tax amount mismatch: expected #{expected_total_including_tax_amount}, got #{draft_invoice.total_including_tax_amount}"
        end

        expected_total_excl_retention_guarantee_amount = expected_total_including_tax_amount * (1 - draft_invoice.context.fetch("project_version_retention_guarantee_rate").to_d)
        unless (draft_invoice.total_excl_retention_guarantee_amount - expected_total_excl_retention_guarantee_amount).abs < AMOUNT_TOLERANCE
          raise StandardError, "Total excluding retention guarantee amount mismatch: expected #{expected_total_excl_retention_guarantee_amount}, got #{draft_invoice.total_excl_retention_guarantee_amount}"
        end
      end
    end
  end
end
