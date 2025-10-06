module Api
  module V1
    module Organization
      class DraftOrdersController < Api::V1::ApiV1Controller
        before_action(only: [ :update, :convert_to_order ]) { load_and_authorise_resource }
        # GET    /api/v1/organization/companies/:company_id/draft_orders
        def index
          draft_orders = policy_scope(::Organization::Project).where(type: "Organization::DraftOrder", client: { company_id: params[:company_id] })
          render json: ::Organization::Projects::DraftOrders::IndexDto.new({ results: draft_orders }).to_json
        end

        # PUT    /api/v1/organization/draft_orders/:id
        def update
          result = ::Organization::DraftOrders::Update.call(@draft_order, update_draft_order_params.to_h)
          raise result.error if result.failure?

          render json: ::Organization::Projects::DraftOrders::ShowDto.new({ result: result.data }).to_json
        end

        # POST    /api/v1/organization/draft_orders/:id/convert_to_order
        def convert_to_order
          result = ::Organization::DraftOrders::ConvertToOrder.call(@draft_order.id)
          raise result.error if result.failure?

          render json: ::Organization::Projects::Orders::ShowDto.new({ result: result.data }).to_json
        end

        # GET    /api/v1/organization/draft_orders/:id
        def show
          draft_order = policy_scope(::Organization::Project).where(type: "Organization::DraftOrder").find(params[:id])
          render json: ::Organization::Projects::DraftOrders::ShowDto.new({ result: draft_order }).to_json
        end

        private

        def update_draft_order_params
          params.require(:draft_order).permit(
            :name,
            :description,
            :retention_guarantee_rate,
            :bank_detail_id,
            :po_number,
            :address_street,
            :address_zipcode,
            :address_city,
            new_items: [
              :group_uuid,
              :name,
              :description,
              :quantity,
              :unit,
              :unit_price_amount,
              :position,
              :tax_rate
            ],
            updated_items: [
              :original_item_uuid,
              :group_uuid,
              :quantity,
              :unit_price_amount,
              :position,
              :tax_rate
            ],
            groups: [
              :uuid,
              :name,
              :description,
              :position
            ]
          )
        end
      end
    end
  end
end
