module Accounting
  module Proformas
    # Creates a proforma with its detail and lines for a project version
    #
    # @param company [Hash] Company data containing:
    #   - id [Integer] The company ID
    #   - name [String] Company name
    #   - registration_number [String] Company registration number
    #   - address_zipcode [String] Company address zip code
    #   - address_street [String] Company street address
    #   - address_city [String] Company city
    #   - vat_number [String] Company VAT number
    #   - config [Hash] Company configuration containing:
    #     - default_vat_rate [Decimal] Default VAT rate
    #     - payment_term_days [Integer] Number of days until payment is due
    #     - payment_term_accepted_methods [Array<String>] Accepted payment methods
    #     - general_terms_and_conditions [String] General terms and conditions
    #     - payment_term [Hash] Payment terms containing:
    #       - days [Integer] Number of days until payment is due
    # @param client [Hash] Client data
    # @param project_version [Hash] Project version data containing:
    #   - id [Integer] The project version ID
    #   - number [Integer] The version number
    #   - created_at [Time] When the version was created
    #   - retention_guarantee_rate [String] The retention guarantee rate as decimal string
    #   - items [Array<Hash>] The project version items containing:
    #     - original_item_uuid [String] Unique identifier for the item
    #     - name [String] Item name
    #     - description [String] Item description
    #     - quantity [Integer] Item quantity
    #     - unit [String] Unit of measure
    #     - unit_price_amount [Integer] Price per unit
    #     - tax_rate [String] Tax rate as decimal string
    #     - group_id [Integer] ID of the item group
    #   - item_groups [Array<Hash>] The project version item groups containing:
    #     - id [Integer] Group ID
    #     - name [String] Group name
    #     - description [String] Group description
    # @param new_invoice_items [Array<Hash>] Items to be invoiced containing:
    #   - original_item_uuid [String] References the project version item
    #   - invoice_amount [Integer] Amount to invoice for this item
    # @param issue_date [Time] When the invoice is issued (defaults to current time)
    #
    # @return [ServiceResult] Success with Invoice or failure with error message
    class Create
    include ApplicationService

        def call(company, client, project, project_version, new_invoice_items, issue_date = Time.current)
          proforma = ActiveRecord::Base.transaction do
            # Create a proforma record
            base_proforma_attributes = build_proforma_attributes!(company.fetch(:id), client.fetch(:id), project, project_version, new_invoice_items, issue_date)
            proforma_number = find_next_available_proforma_number!(company.fetch(:id), issue_date)
            proforma = Proforma.create!(base_proforma_attributes.merge({ number: proforma_number }))

            # Create proforma line records
            proforma_lines_attributes = build_proforma_lines_attributes!(proforma.context, new_invoice_items)
            proforma.lines.create!(proforma_lines_attributes)

            # Create proforma details records
            proforma_detail_attributes = build_proforma_detail_attributes!(company, client, project_version, issue_date)
            proforma.create_detail!(proforma_detail_attributes)

            # Verify that totals recorded in draft_invoice are in line with its lines as this is crucial, better be safe than sorry
            ensure_totals_are_correct!(proforma)

            proforma
          end

          FinancialTransactions::GenerateAndAttachPdfJob.perform_async({ "financial_transaction_id" => proforma.id })

          proforma
        end

        private

        def build_proforma_attributes!(company_id, client_id, project, project_version, new_invoice_items, issue_date)
          result = BuildAttributes.call(company_id, client_id, project, project_version, new_invoice_items, issue_date)

          raise result.error if result.failure?
          result.data
        end

        def build_proforma_lines_attributes!(proforma_context, proforma_items)
          result = BuildLinesAttributes.call(proforma_context, proforma_items)

          raise result.error if result.failure?
          result.data
        end

        def build_proforma_detail_attributes!(company, client, project_version, issue_date)
          result = BuildDetailAttributes.call(company, client, project_version, issue_date)

          raise result.error if result.failure?
          result.data
        end

        def find_next_available_proforma_number!(company_id, issue_date)
          result = FinancialTransactions::FindNextAvailableNumber.call(company_id: company_id, prefix: Proforma::NUMBER_PREFIX, issue_date: issue_date)

          raise result.error if result.failure?
          result.data
        end

        def ensure_totals_are_correct!(draft_invoice)
          expected_total_excl_tax_amount = draft_invoice.lines.sum("quantity * unit_price_amount")
          unless (expected_total_excl_tax_amount - draft_invoice.total_excl_tax_amount).round(2).zero?
            raise Error::UnprocessableEntityError, "Total excluding tax amount mismatch: expected #{expected_total_excl_tax_amount}, got #{draft_invoice.total_excl_tax_amount}"
          end

          expected_total_including_tax_amount = draft_invoice.lines.sum("quantity * unit_price_amount * (1 + tax_rate)")
          unless (draft_invoice.total_including_tax_amount - expected_total_including_tax_amount).round(2).zero?
            raise Error::UnprocessableEntityError, "Total including tax amount mismatch: expected #{expected_total_including_tax_amount}, got #{draft_invoice.total_including_tax_amount}"
          end

          expected_total_excl_retention_guarantee_amount = expected_total_including_tax_amount * (1 - draft_invoice.context.fetch("project_version_retention_guarantee_rate").to_d)
          unless (draft_invoice.total_excl_retention_guarantee_amount - expected_total_excl_retention_guarantee_amount).round(2).zero?
            raise StandardError, "Total excluding retention guarantee amount mismatch: expected #{expected_total_excl_retention_guarantee_amount}, got #{draft_invoice.total_excl_retention_guarantee_amount}"
          end
        end
    end
  end
end
