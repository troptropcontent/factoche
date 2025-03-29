class Api::V1::Organization::CompaniesController < Api::V1::ApiV1Controller
  # GET /api/v1/organization/companies
  def index
    companies = policy_scope(Organization::Company)

    render json: Organization::CompanySerializer.render(companies)
  end

  # GET /api/v1/organization/companies/:id
  def show
    company = policy_scope(Organization::Company).find(params[:id])

    render json: Organization::Companies::ShowDto.new({ result: company }).to_json
  end
end
