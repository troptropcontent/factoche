module Api
  module V1
    module Organization
      class CreditNotesController < ApiV1Controller
        # GET    /api/v1/organization/companies/:company_id/credit_notes
        def index
          credit_notes = policy_scope(Accounting::CreditNote).where(company_id: params[:company_id]).order(:number)

          render json: ::Organization::CreditNotes::IndexDto.new({ results: credit_notes })
        end
      end
    end
  end
end
