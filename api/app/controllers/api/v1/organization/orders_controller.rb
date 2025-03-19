module Api
  module V1
    module Organization
      class OrdersController < Api::V1::ApiV1Controller
        # GET    /api/v1/organization/companies/:company_id/orders
        def index
          orders = policy_scope(::Organization::Project).where(type: "Organization::Order", client: { company_id: params[:company_id] })
          render json: ::Organization::Projects::Orders::IndexDto.new({ results: orders }).to_json
        end

        # GET    /api/v1/organization/orders/:id
        def show
          order = policy_scope(::Organization::Project).where(type: "Organization::Order").find(params[:id])
          render json: ::Organization::Projects::Orders::ShowDto.new({ result: order }).to_json
        end

        # GET  /api/v1/organization/orders/:id/invoiced_items
        def invoiced_items
          order = policy_scope(::Organization::Project).where(type: "Organization::Order").find(params[:id])

          result = ::Organization::Projects::GetInvoicedAmountForProjectItems.call(order.client.company_id, order.id)

          raise Error::UnprocessableEntityError.new(result.error) unless result.success?

          render json: ::Organization::Projects::InvoicedItemsDto.new({ results: result.data })
        end
      end
    end
  end
end
