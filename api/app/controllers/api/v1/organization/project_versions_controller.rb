class Api::V1::Organization::ProjectVersionsController < Api::V1::ApiV1Controller
  before_action :load_and_authorise_company!
  # GET /api/v1/organization/companies/{company_id}/projects/{project_id}/versions
  def index
    versions = policy_scope(Organization::ProjectVersion).where({ project: { organization_clients: { company_id: @company.id  }, id: params[:project_id] } })

    render json: Organization::ProjectVersionIndexResponseDto.new({ results: versions }).to_json
  end

  # GET /api/v1/organization/companies/{company_id}/projects/{project_id}/versions/{:id}
  def show
    version = policy_scope(Organization::ProjectVersion).where({ project: { organization_clients: { company_id: @company.id  }, id: params[:project_id] } }).find(params[:id])

    render json: Organization::ProjectVersionShowResponseDto.new({ result: version }).to_json
  end

  private

  def load_and_authorise_company!
    @company = Organization::Company.find(params[:company_id])

    raise Error::UnauthorizedError unless policy_scope(Organization::Company).exists?({ id: @company.id })
  end
end
