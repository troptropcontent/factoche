module Api
  module V1
    module Organization
      class QuotesController < Api::V1::ApiV1Controller
        before_action(only: [ :show, :update ]) { load_and_authorise_resource(name: :quote, param_key: :id,  class_name: "Organization::Quote") }
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
          bank_detail = @quote.company.bank_details.find(params.require(:quote).require(:bank_detail_id))
          result = ::Organization::Quotes::Update.call(@quote, params[:quote].to_unsafe_h.merge({ bank_detail_id: bank_detail.id }))
          raise result.error if result.failure?

          render json: ::Organization::Projects::Quotes::ShowDto.new({ result: result.data }).to_json
        end

        # POST    /api/v1/organization/companies/:company_id/clients/:client_id/quotes
        def create
          company = policy_scope(::Organization::Company).find(params[:company_id])
          client = company.clients.find(params[:client_id])
          bank_detail = company.bank_details.find(params[:bank_detail_id])

          result = ::Organization::Quotes::Create.call(company.id, client.id, bank_detail.id, params[:quote].to_unsafe_h)
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
        # Strong params removed - validation is handled by dry-validation contracts in services
      end
    end
  end
end
