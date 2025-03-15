module Api
  module V1
    module Organization
      class InvoicesController < ApiV1Controller
        # GET /api/v1/organization/projects/:project_id/invoices
        def index
          project = policy_scope(::Organization::Project).find(params[:project_id])

          invoices = Accounting::Invoice
            .left_outer_joins(:lines)
            .select(
              "accounting_financial_transactions.*, " \
              "SUM(COALESCE(accounting_financial_transaction_lines.quantity, 0) * " \
              "COALESCE(accounting_financial_transaction_lines.unit_price_amount, 0)) as total_amount"
            )
            .where(holder_id: project.versions.pluck(:id))
            .then { |invoices| filter_by_status(invoices) }
            .group("accounting_financial_transactions.id")

          render json: ::Organization::Invoices::IndexDto.new({ results: invoices })
        end

        # GET  /api/v1/organization/projects/:project_id/invoices/:id
        def show
          project = policy_scope(::Organization::Project).find(params[:project_id])

          invoice = Accounting::Invoice.where(holder_id: project.versions.pluck(:id)).includes(:lines).find(params[:id])

          render json: ::Organization::Invoices::ShowDto.new({ result: invoice })
        end

        # POST /api/v1/organization/projects/:project_id/invoices/completion_snapshot
        def create
          project = policy_scope(::Organization::Project).find(params[:project_id])
          project_version = project.last_version

          result = ::Organization::Invoices::Create.call(project_version.id, invoice_params.to_h)

          if result.failure?
            raise Error::UnprocessableEntityError, "Failed to create completion snapshot invoice: #{result.error}"
          end

          render json: ::Organization::Invoices::ShowDto.new({ result: result.data })
        end

        # PUT  /api/v1/organization/projects/:project_id/invoices/:id
        def update
          project = policy_scope(::Organization::Project).find(params[:project_id])

          invoice = Accounting::Invoice.where(holder_id: project.versions.pluck(:id)).includes(:lines).find(params[:id])

          result = ::Organization::Invoices::Update.call(invoice.id, invoice_params.to_h)

          if result.failure?
            raise Error::UnprocessableEntityError, "Failed to update invoice: #{result.error}"
          end

          render json: ::Organization::Invoices::ShowDto.new({ result: result.data })
        end

        # DELETE  /api/v1/organization/projects/:project_id/invoices/:id
        def destroy
          project = policy_scope(::Organization::Project).find(params[:project_id])

          invoice = Accounting::Invoice.where(holder_id: project.versions.pluck(:id)).includes(:lines).find(params[:id])

          result = ::Accounting::Invoices::Void.call(invoice.id)

          if result.failure?
            raise Error::UnprocessableEntityError, "Failed to void invoice: #{result.error}"
          end

          render json: ::Organization::Invoices::ShowDto.new({ result: result.data })
        end

        # POST  /api/v1/organization/projects/:project_id/invoices/:id
        def post
          project = policy_scope(::Organization::Project).find(params[:project_id])

          invoice = Accounting::Invoice.where(holder_id: project.versions.pluck(:id)).includes(:lines).find(params[:id])

          result = ::Accounting::Invoices::Post.call(invoice.id)

          if result.failure?
            raise Error::UnprocessableEntityError, "Failed to post invoice: #{result.error}"
          end

          render json: ::Organization::Invoices::ShowDto.new({ result: result.data })
        end

        private

        def invoice_params
          params.require(:invoice).permit(invoice_amounts: [ :original_item_uuid, :invoice_amount ])
        end

        def filter_by_status(invoices)
          return invoices unless params[:status].present?

          statuses = Array(params[:status])
          invoices.where(status: statuses)
        end
      end
    end
  end
end
