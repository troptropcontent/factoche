module Api
  module V1
    module Organization
      class CreditNotesController < ApiV1Controller
        before_action(except: [ :index ]) { load_and_authorise_resource(class_name: "Accounting::CreditNote") }

        # GET    /api/v1/organization/companies/:company_id/credit_notes
        def index
          credit_notes = policy_scope(Accounting::CreditNote).where(company_id: params[:company_id]).order(:number)

          render json: ::Organization::CreditNotes::IndexDto.new({ results: credit_notes })
        end

        # GET    /api/v1/organization/credit_notes/:id
        def show
          render json: ::Organization::CreditNotes::ShowDto.new({ result: @credit_note })
        end
      end
    end
  end
end
