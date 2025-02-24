class Api::V1::Organization::CompletionSnapshotsController < Api::V1::ApiV1Controller
  before_action(only: :create) { load_and_authorise_resource(:project, class_name: "Organization::Project") }
  # POST /api/v1/organization/companies/:company_id/projects/:project_id/completion_snapshots
  def create
    dto = Organization::CreateCompletionSnapshotDto.new(completion_snapshot_params)
    completion_snapshot = Organization::CreateCompletionSnapshot.call(dto, params[:project_id])

    render json: Organization::CompletionSnapshots::ShowDto.new({ result: completion_snapshot }).to_json
  end

  # POST /api/v1/organization/completion_snapshots/:id/cancel
  def cancel
    snapshot = policy_scope(Organization::CompletionSnapshot).find(params[:id])
    result = Organization::CompletionSnapshots::Cancel.call(snapshot)

    if result.success?
      render json: Organization::CompletionSnapshots::ShowDto.new({ result: snapshot.reload }).to_json
    else
      raise Error::UnprocessableEntityError, "Unable to cancel completion snapshot, the following error occurred: #{result.error}"
    end
  end

  # GET /api/v1/project_versions/:project_version_id/completion_snapshots/new_completion_snapshot_data
  def new_completion_snapshot_data
    project_version = policy_scope(Organization::ProjectVersion).find(params[:project_version_id])
    unless project_version.is_last_version?
      raise Error::UnauthorizedError, "Cannot build completion data for a version that is not the last one"
    end

    new_snapshot = project_version.completion_snapshots.new
    new_snapshot.invoice = Organization::BuildInvoiceFromCompletionSnapshot.call(new_snapshot, Time.current)

    render json: Organization::CompletionSnapshots::NewCompletionSnapshotDataDto.new({ result: new_snapshot }).to_json
  end

  # PUT /api/v1/organization/completion_snapshots/:id
  def update
    snapshot = policy_scope(Organization::CompletionSnapshot).find(params[:id])
    dto = Organization::CompletionSnapshots::UpdateDto.new(completion_snapshot_params)

    completion_snapshot = Organization::UpdateCompletionSnapshot.call(dto, snapshot)

    render json: Organization::CompletionSnapshots::ShowDto.new({ result: completion_snapshot }).to_json
  end

  # POST /api/v1/organization/completion_snapshots/:id/publish
  def publish
    snapshot = policy_scope(Organization::CompletionSnapshot).find(params[:id])

    updated_snapshot, _ = Organization::TransitionCompletionSnapshotToInvoiced.call(snapshot, Time.current)

    render json: Organization::CompletionSnapshots::ShowDto.new({ result: updated_snapshot }).to_json
  end

  # DELETE /api/v1/organization/completion_snapshots/:id
  def destroy
    snapshot = policy_scope(Organization::CompletionSnapshot).find(params[:id])

    Organization::DestroyCompletionSnapshot.call(snapshot)

    head :no_content
  end

  # GET  /api/v1/organization/completion_snapshots/:id
  def show
    snapshot = policy_scope(Organization::CompletionSnapshot).find(params[:id])

    render json: Organization::CompletionSnapshots::ShowDto.new({ result: snapshot }).to_json
  end

  # GET  /api/v1/organization/completion_snapshots/:id/previous
  def previous
    scope = policy_scope(Organization::CompletionSnapshot)
    base_snapshot = scope.find(params[:id])
    previous_snapshot = scope
      .where(
        "organization_projects.id = ? AND organization_completion_snapshots.created_at < ?",
        base_snapshot.project_version.project_id,
        base_snapshot.created_at
      )
      .order(created_at: :desc)
      .limit(1)
      .first

    render json: Organization::CompletionSnapshots::PreviousDto.new({ result: previous_snapshot }).to_json
  end

  # GET  /api/v1/organization/completion_snapshots
  def index
    filter_dto = Organization::CompletionSnapshotIndexRequestDto.new(filter_params)
    query_dto = QueryParamsDto.new(query_params)

    snapshots = policy_scope(Organization::CompletionSnapshot).then { |scope| filter_snapshots(scope, filter_dto) }
                                                              .then { |filtered_snapshots| limited_snapshots(filtered_snapshots, query_dto.limit) }
                                                              .order(created_at: :desc)

    render json: Organization::CompletionSnapshots::IndexDto.new({ results: snapshots }).to_json
  end

  private

  def completion_snapshot_params
    params.require(:completion_snapshot).permit(:description, completion_snapshot_items: [ :completion_percentage, :item_id, :id ])
  end

  def filter_params
    params[:filter]&.permit(:company_id, :project_id, :project_version_id) || ActionController::Parameters.new({})
  end

  def query_params
    params[:query]&.permit(:limit) || ActionController::Parameters.new({})
  end

  def filter_snapshots(scope, dto)
    scope = scope.where("organization_companies.id = ?", dto.company_id) if dto.company_id.present?
    scope = scope.where("organization_project_versions.project_id = ?", dto.project_id) if dto.project_id.present?
    scope = scope.where("organization_project_versions.id = ?", dto.project_version_id) if dto.project_version_id.present?
    scope
  end

  def limited_snapshots(relation, limit)
    limit ? relation.limit(limit) :  relation
  end
end
