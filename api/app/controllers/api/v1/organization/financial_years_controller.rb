module Api
  module V1
    module Organization
      class FinancialYearsController < ApiV1Controller
        before_action(only: [ :index, :create ]) { load_and_authorise_resource(name: :company, param_key: "company_id", class_name: "Organization::Company") }
        before_action(only: [ :renew ]) { load_and_authorise_resource(class_name: "Accounting::FinancialYear") }

        # GET /api/v1/organization/companies/:company_id/financial_years
        def index
          financial_years = policy_scope(Accounting::FinancialYear)
            .where(company_id: @company.id)
            .order(:start_date)

          render json: ::Organization::FinancialYears::IndexDto.new({ results: financial_years })
        end

        # POST /api/v1/organization/companies/:company_id/financial_years
        def create
          result = Accounting::FinancialYears::Create.call(
            company_id: @company.id,
            start_date: financial_year_params[:start_date],
            end_date: financial_year_params[:end_date]
          )

          raise Error::UnprocessableEntityError, result.error if result.failure?

          render json: ::Organization::FinancialYears::ShowDto.new({ result: result.data }), status: :created
        end

        # POST /api/v1/organization/financial_years/:id/renew
        def renew
          result = Accounting::FinancialYears::Renew.call(@financial_year.id)

          raise Error::UnprocessableEntityError, result.error if result.failure?

          render json: ::Organization::FinancialYears::ShowDto.new({ result: result.data }), status: :created
        end

        private

        def financial_year_params
          params.require(:financial_year).permit(:start_date, :end_date)
        end
      end
    end
  end
end
