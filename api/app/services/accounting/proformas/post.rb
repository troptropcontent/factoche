module Accounting
  module Proformas
    # Post and proforma by posting the current one and creating a new posted invoice identical
    # @param proforma_id [Integer] ID of the proforma to post
    # @param issue_date [Time] When the duplicate invoice should be issued (defaults to current time)
    #
    # @return [ServiceResult] Success with duplicated Invoice or failure with error message
    class Post
      include ApplicationService
        def call(proforma_id, issue_date = Time.current)
          @original_proforma = Accounting::Proforma.find(proforma_id)
          @issue_date = issue_date

          ensure_proforma_is_draft!

          ActiveRecord::Base.transaction do
            post_original_proforma!

            find_financial_year!

            find_next_available_invoice_number!

            create_invoice_from_original_proforma!
          end

          FinancialTransactions::GenerateAndAttachPdfJob.perform_async({ "financial_transaction_id" => @invoice.id })

          @invoice
        end

        private

        def find_financial_year!
          result = FinancialYears::FindFromDate.call(@original_proforma.company_id, @issue_date)

          raise ArgumentError, "Financial year not found for the given date" unless result.success?

          @financial_year = result.data
        end

        def post_original_proforma!
          @original_proforma.update!(status: :posted)
        end

        def find_next_available_invoice_number!
          result = FinancialTransactions::FindNextAvailableNumber.call(company_id: @original_proforma.company_id, financial_year_id: @financial_year.id, prefix: Invoice::NUMBER_PREFIX, issue_date: @issue_date)

          raise result.error unless result.success?

          @next_available_invoice_number = result.data
        end

        def create_invoice_from_original_proforma!
          create_invoice!
          create_lines!
          create_details!
        end

        def create_invoice!
          base_attributes = @original_proforma.attributes.except(
            "id", "number", "status", "created_at", "updated_at", "type"
          ).merge({
            "number" => @next_available_invoice_number,
            "status" => "posted",
            "issue_date" => @issue_date
          })

          # Create duplicated invoice
          @invoice = Accounting::Invoice.create!(base_attributes)
        end

        def create_lines!
          @original_proforma.lines.each do |line|
            line_attributes = line.attributes.except("id", "invoice_id", "created_at", "updated_at")
            @invoice.lines.create!(line_attributes)
          end
        end

        def create_details!
          detail_attributes = @original_proforma.detail.attributes.except(
                "id", "invoice_id", "created_at", "updated_at"
          ).merge({
            "due_date" => @issue_date + @original_proforma.detail.payment_term_days.days,
            "delivery_date" => @issue_date
          })

          @invoice.create_detail!(detail_attributes)
        end

        def ensure_proforma_is_draft!
          unless @original_proforma.status == "draft"
            raise ArgumentError, "Cannot post proforma that is not in draft status"
          end
        end
    end
  end
end
