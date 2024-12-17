class Api::V1::Organization::CompaniesController < Api::V1::ApiV1Controller
  # GET /api/v1/organization/companies
  def index
    companies = policy_scope(Organization::Company)

    render json: Organization::CompanySerializer.render(companies)
  end
end
