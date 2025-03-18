module Api
  module V1
    module Organization
      class QuotesController < Api::V1::ApiV1Controller
        # GET    /api/v1/organization/companies/:company_id/quotes
        def index
          quotes = policy_scope(::Organization::Project).where(type: "Organization::Quote", client: { company_id: params[:company_id] })
          render json: ::Organization::Projects::Quotes::IndexDto.new({ results: quotes }).to_json
        end
      end
    end
  end
end
