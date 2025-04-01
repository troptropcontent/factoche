module Api
  module V1
    module Organization
      class DraftOrdersController < Api::V1::ApiV1Controller
        # GET    /api/v1/organization/companies/:company_id/draft_orders
        def index
          draft_orders = policy_scope(::Organization::Project).where(type: "Organization::DraftOrder", client: { company_id: params[:company_id] })
          render json: ::Organization::Projects::DraftOrders::IndexDto.new({ results: draft_orders }).to_json
        end

        # GET    /api/v1/organization/draft_orders/:id
        def show
          draft_order = policy_scope(::Organization::Project).where(type: "Organization::DraftOrder").find(params[:id])
          render json: ::Organization::Projects::DraftOrders::ShowDto.new({ result: draft_order }).to_json
        end
      end
    end
  end
end
