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

        # POST    /api/v1/organization/companies/:company_id/clients/:client_id/quotes
        def create
          company = policy_scope(::Organization::Company).find(params[:company_id])
          client = company.clients.find(params[:client_id])

          result = ::Organization::Quotes::Create.call(client.id, quote_params.to_h)
          raise result.error if result.failure?

          render json: ::Organization::Projects::Quotes::ShowDto.new({ result: result.data }).to_json, status: :created
        end

        # POST    /api/v1/organization/quotes/:id/convert_to_order
        def convert_to_order
          quote = policy_scope(::Organization::Project).where(type: "Organization::Quote").find(params[:id])

          result = ::Organization::Quotes::ConvertToOrder.call(quote.last_version.id)
          raise Error::UnprocessableEntityError, result.error if result.failure?

          render json: ::Organization::Projects::Orders::ShowDto.new({ result: result.data }).to_json, status: :created
        end

        private

        def quote_params
          params.require(:quote).permit(
            :name,
            :description,
            :retention_guarantee_rate,
            items: [
              :group_uuid,
              :name,
              :description,
              :quantity,
              :unit,
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
