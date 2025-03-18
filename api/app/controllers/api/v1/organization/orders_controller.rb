module Api
  module V1
    module Organization
      class OrdersController < Api::V1::ApiV1Controller
        # GET    /api/v1/organization/companies/:company_id/orders
        def index
          orders = policy_scope(::Organization::Project).where(type: "Organization::Order", client: { company_id: params[:company_id] })
          render json: ::Organization::Projects::Orders::IndexDto.new({ results: orders }).to_json
        end
      end
    end
  end
end
