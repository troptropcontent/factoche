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
          bank_detail = @draft_order.company.bank_details.find(params.require(:draft_order).require(:bank_detail_id))
          result = ::Organization::DraftOrders::Update.call(@draft_order, params[:draft_order].to_unsafe_h.merge({ bank_detail_id: bank_detail.id }))
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
        # Strong params removed - validation is handled by dry-validation contracts in services
      end
    end
  end
end
