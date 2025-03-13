module Accounting
  module FinancialTransactions
    class CreateInvoice
      class << self
        # Creates a invoice with its detail and invoice lines for a project version
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
        # @return [ServiceResult] Success with CompletionSnapshotInvoice or failure with error message
        def call(company, client, project_version, new_invoice_items, issue_date = Time.current)
          invoice = ActiveRecord::Base.transaction do
            # Create invoice record
            draft_invoice_attributes = build_draft_invoice_attributes!(company.fetch(:id), project_version, issue_date)
            draft_invoice = Accounting::CompletionSnapshotInvoice.create!(draft_invoice_attributes)

            # Create invoice line records
            draft_invoice_lines_attributes = build_invoice_lines_attributes!(draft_invoice.context, new_invoice_items)
            draft_invoice.lines.create!(draft_invoice_lines_attributes)

            # Create invoice details records
            draft_invoice_detail_attributes = build_invoice_detail_attributes!(company, client, project_version, issue_date)
            draft_invoice.create_detail!(draft_invoice_detail_attributes)
            draft_invoice
          end

          ServiceResult.success(invoice)
        rescue StandardError => e
          ServiceResult.failure("Failed to create invoice: #{e.message}")
        end

        private

        def build_draft_invoice_attributes!(company_id, project_version, issue_date)
          result = BuildCompletionSnapshotInvoiceAttributes.call(company_id, project_version, issue_date)

          raise result.error if result.failure?
          result.data
        end

        def build_invoice_lines_attributes!(draft_invoice_context, new_invoice_items)
          result = BuildCompletionSnapshotInvoiceLinesAttributes.call(draft_invoice_context, new_invoice_items)

          raise result.error if result.failure?
          result.data
        end

        def build_invoice_detail_attributes!(company, client, project_version, issue_date)
          result = BuildCompletionSnapshotInvoiceDetailAttributes.call(company, client, project_version, issue_date)

          raise result.error if result.failure?
          result.data
        end
      end
    end
  end
end
