module Api
  module V1
    module Organization
      class QuotesController < Api::V1::ApiV1Controller
        # GET    /api/v1/organization/companies/:company_id/quotes
        def index
          quotes = policy_scope(::Organization::Project).where(type: "Organization::Quote", client: { company_id: params[:company_id] })
          render json: ::Organization::Projects::Quotes::IndexDto.new({ results: quotes }).to_json
        end

        # GET    /api/v1/organization/quotes/:id
        def show
          quote = policy_scope(::Organization::Project).where(type: "Organization::Quote").find(params[:id])
          render json: ::Organization::Projects::Quotes::ShowDto.new({ result: quote }).to_json
        end
      end
    end
  end
end
