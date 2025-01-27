class Api::V1::Organization::CompletionSnapshotsController < Api::V1::ApiV1Controller
  before_action(only: :create) { load_and_authorise_resource(:project, class_name: "Organization::Project") }
  # POST /api/v1/organization/companies/:company_id/projects/:project_id/completion_snapshots
  def create
    dto = Organization::CreateCompletionSnapshotDto.new(completion_snapshot_params)
    completion_snapshot = Organization::CreateCompletionSnapshot.call(dto, params[:project_id])

    render json: Organization::ShowCompletionSnapshotResponseDto.new({ result: completion_snapshot }).to_json
  end

  # GET  /api/v1/organization/completion_snapshots/:id
  def show
    snapshot = policy_scope(Organization::CompletionSnapshot).find(params[:id])

    render json: Organization::ShowCompletionSnapshotResponseDto.new({ result: snapshot }).to_json
  end

  private

  def completion_snapshot_params
    params.require(:completion_snapshot).permit(:description, completion_snapshot_items: [ :completion_percentage, :item_id ])
  end
end
