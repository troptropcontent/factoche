class Api::V1::Organization::CompletionSnapshotsController < Api::V1::ApiV1Controller
  before_action { load_and_authorise_resource(:company, class_name: "Organization::Company") }
  # POST /api/v1/organization/companies/:company_id/projects/:project_id/completion_snapshots
  def create
    byebug
  end

  private

  def completion_snapshot_params
    params.require(:completion_snapshot).permit(:description, completion_snapshot_items: [ :completion_percentage, :item_id ])
  end
end
