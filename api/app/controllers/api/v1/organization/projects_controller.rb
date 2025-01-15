class Api::V1::Organization::ProjectsController < Api::V1::ApiV1Controller
  before_action :load_company!

  # POST /api/v1/organization/companies/:company_id/projects
  def create
    project = Organization::CreateProject.call(create_project_dto)
    render json: serialize_project(project)
  end

  private

  def load_company!
    @company = policy_scope(Organization::Company).find_by(id: params[:company_id])
    raise Error::NotFoundError unless @company
  end

  def client_id_params
    params.require(:project).require(:client_id)
  end

  def project_params
    params.require(:project).permit(
      :name,
      :description,
      :retention_guarantee_rate,
      :client_id,
      items: [
        :name,
        :description,
        :position,
        :quantity,
        :unit,
        :unit_price_cents,
        items: [
          :name,
          :description,
          :position,
          :quantity,
          :unit,
          :unit_price_cents
        ]
      ]
    )
  end

  def create_project_dto
    Organization::CreateProjectDto.new(project_params)
  end

  def serialize_project(project)
    Organization::ProjectDto.new(project_dto_params(project)).to_json
  end

  def project_dto_params(project)
    {
      id: project.id,
      name: project.name,
      client_id: project.client_id,
      description: project.description,
      versions: project.versions.map { |version| {
        id: version.id,
        number: version.number,
        retention_rate_guarantee: version.retention_guarantee_rate,
        items: items_params(version)
      }}
    }
  end

  def items_params(project_version)
    item_groups = project_version.item_groups
    if item_groups.length > 0
      item_groups.map { |item_group| {
        id: item_group.id,
        name: item_group.name,
        description: item_group.description,
        position: item_group.position,
        items: item_group.items.map { |item| {
          id: item.id,
          name: item.name,
          quantity: item.quantity,
          unit_price_cents: item.unit_price_cents,
          unit: item.unit,
          position: item.position
        }}
      }}
    else
      project_version.items.map { |item| {
        id: item.id,
        name: item.name,
        quantity: item.quantity,
        unit_price_cents: item.unit_price_cents,
        unit: item.unit,
        position: item.position
      }}
    end
  end

  def create_project_dto
    Organization::CreateProjectDto.new(project_params)
  end

  def serialize_project(project)
    Organization::ProjectDto.new(project_dto_params(project)).to_json
  end
end
