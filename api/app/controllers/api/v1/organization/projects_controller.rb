class Api::V1::Organization::ProjectsController < Api::V1::ApiV1Controller
  before_action :load_company!
  # POST /api/v1/organization/companies/:company_id/projects
  def create
    head :ok
  end

  private

  def load_company!
    @company = policy_scope(Organization::Company).find_by(id: params[:company_id])
    raise Error::NotFoundError unless @company
  end
end
