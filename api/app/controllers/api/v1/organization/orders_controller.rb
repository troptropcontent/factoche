module Api
  module V1
    module Organization
      class OrdersController < Api::V1::ApiV1Controller
        before_action(only: [ :update ]) { load_and_authorise_resource }

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

        # PUT    /api/v1/organization/orders/:id
        def update
          bank_detail = @order.company.bank_details.find(params.require(:order).require(:bank_detail_id))
          result = ::Organization::Orders::Update.call(@order.id, params[:order].to_unsafe_h.merge({ bank_detail_id: bank_detail.id }))
          raise result.error if result.failure?

          render json: ::Organization::Projects::Orders::ShowDto.new({ result: result.data }).to_json
        end

        # GET  /api/v1/organization/orders/:id/invoiced_items
        def invoiced_items
          order = policy_scope(::Organization::Project).where(type: "Organization::Order").find(params[:id])

          result = ::Organization::Orders::FetchInvoicedAmountPerItems.call(order.id)

          raise Error::UnprocessableEntityError.new(result.error) unless result.success?

          items = ::Organization::Item.where(project_version_id: order.versions.pluck(:id)).order(:original_item_uuid)
          results = items.map do |item|
            {
              original_item_uuid: item.original_item_uuid,
              invoiced_amount: result.data[item.original_item_uuid][:invoices_amount] - result.data[item.original_item_uuid][:credit_notes_amount]
            }
          end

          render json: ::Organization::Projects::Orders::InvoicedItemsDto.new({ results: results }).to_json
        end

        private
        # Strong params removed - validation is handled by dry-validation contracts in services
      end
    end
  end
end
