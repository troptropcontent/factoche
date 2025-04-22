module Api
  module V1
    module Organization
      class InvoicesController < ApiV1Controller
        before_action :load_invoice!, except: [ :index ]
        # GET    /api/v1/organization/companies/:company_id/invoices
        def index
          invoices = policy_scope(Accounting::Invoice).where(company_id: params[:company_id])
            .then { |invoices| filter_by_status(invoices) }
            .then { |invoices| filter_by_order(invoices) }
            .order(:number)

          order_versions = ::Organization::ProjectVersion.where(id: invoices.pluck(:holder_id))

          orders = ::Organization::Order.where(id: order_versions.pluck(:project_id))

          render json: ::Organization::Invoices::IndexDto.new({ results: invoices, meta: { order_versions: order_versions, orders: orders } })
        end

        # GET    /api/v1/organization/companies/:company_id/invoices/:id
        def show
          render json: ::Organization::Invoices::ShowDto.new({ result: @invoice })
        end

        # POST   /api/v1/organization/companies/:company_id/invoices/:id/cancel
        def cancel
          result = ::Accounting::Invoices::Cancel.call(@invoice.id)

          if result.failure?
            raise Error::UnprocessableEntityError, "Failed to cancel invoice: #{result.error}"
          end

          render json: ::Organization::Invoices::ShowDto.new({ result: result.data[:invoice] })
        end

        # POST   /api/v1/organization/companies/:company_id/invoices/:id
        def post
          result = ::Accounting::Invoices::Post.call(@invoice.id)

          if result.failure?
            raise Error::UnprocessableEntityError, "Failed to post invoice: #{result.error}"
          end

          render json: ::Organization::Invoices::ShowDto.new({ result: result.data })
        end

        private

        def load_invoice!
          @invoice = policy_scope(Accounting::Invoice).where(company_id: params[:company_id]).includes(:lines).find(params[:id])
        end

        def invoice_params
          params.require(:invoice).permit(invoice_amounts: [ :original_item_uuid, :invoice_amount ])
        end

        def filter_by_status(invoices)
          return invoices unless params[:status].present?

          statuses = Array(params[:status])
          invoices.where(status: statuses)
        end

        def filter_by_order(invoices)
          return invoices unless params[:order_id].present?
          order_version_ids = ::Organization::ProjectVersion.where(project_id: params[:order_id]).pluck(:id)
          invoices.where(holder_id: order_version_ids)
        end
      end
    end
  end
end
