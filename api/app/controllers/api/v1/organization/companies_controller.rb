class Api::V1::Organization::CompaniesController < Api::V1::ApiV1Controller
  # GET /api/v1/organization/companies
  def index
    companies = policy_scope(Organization::Company)

    render json: Organization::CompanySerializer.render(companies)
  end

  # GET /api/v1/organization/:id
  def show
    company = policy_scope(Organization::Company).find_by(id: params[:id])
    raise Error::NotFoundError unless company

    render json: Organization::CompanySerializer.render(company)
  end
end
