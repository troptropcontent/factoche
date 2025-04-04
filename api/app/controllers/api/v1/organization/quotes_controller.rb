module Api
  module V1
    module Organization
      class QuotesController < Api::V1::ApiV1Controller
        before_action(only: [ :show, :update ]) { load_and_authorise_resource(:quote, param_key: :id,  class_name: "Organization::Quote") }
        # GET    /api/v1/organization/companies/:company_id/quotes
        def index
          quotes = policy_scope(::Organization::Project).where(type: "Organization::Quote", client: { company_id: params[:company_id] })
          render json: ::Organization::Projects::Quotes::IndexDto.new({ results: quotes }).to_json
        end

        # GET    /api/v1/organization/quotes/:id
        def show
          render json: ::Organization::Projects::Quotes::ShowDto.new({ result: @quote }).to_json
        end

        # PUT    /api/v1/organization/quotes/:id
        def update
          result = ::Organization::Quotes::Update.call(@quote, update_quote_params.to_h)
          raise result.error if result.failure?

          render json: ::Organization::Projects::Quotes::ShowDto.new({ result: result.data }).to_json
        end

        # POST    /api/v1/organization/companies/:company_id/clients/:client_id/quotes
        def create
          company = policy_scope(::Organization::Company).find(params[:company_id])
          client = company.clients.find(params[:client_id])

          result = ::Organization::Quotes::Create.call(company.id, client.id, quote_params.to_h)
          raise result.error if result.failure?

          render json: ::Organization::Projects::Quotes::ShowDto.new({ result: result.data }).to_json, status: :created
        end

        # POST    /api/v1/organization/quotes/:id/convert_to_draft_order
        def convert_to_draft_order
          quote = policy_scope(::Organization::Project).where(type: "Organization::Quote").find(params[:id])

          result = ::Organization::Quotes::ConvertToDraftOrder.call(quote.id)
          raise Error::UnprocessableEntityError, result.error if result.failure?

          render json: ::Organization::Projects::DraftOrders::ShowDto.new({ result: result.data }).to_json, status: :created
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

        def update_quote_params
          params.require(:quote).permit(
            :name,
            :description,
            :retention_guarantee_rate,
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
