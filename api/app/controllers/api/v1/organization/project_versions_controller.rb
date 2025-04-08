class Api::V1::Organization::ProjectVersionsController < Api::V1::ApiV1Controller
  before_action(except: :show) { load_and_authorise_resource(name: :company, param_key: "company_id", class_name: "Organization::Company") }
  # GET /api/v1/organization/companies/{company_id}/orders/{order_id}/versions
  def index
    versions = policy_scope(Organization::ProjectVersion).where({ project: { organization_clients: { company_id: @company.id  }, id: params[:order_id] } })

    render json: Organization::ProjectVersionIndexResponseDto.new({ results: versions }).to_json
  end

  # GET  /api/v1/organization/project_versions/:id
  def show
    version = policy_scope(Organization::ProjectVersion).find(params[:id])

    render json: Organization::ProjectVersions::ShowDto.new({ result: version }).to_json
  end
end
