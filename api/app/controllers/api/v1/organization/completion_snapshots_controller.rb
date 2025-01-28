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

  # GET  /api/v1/organization/completion_snapshots
  def index
    filter_dto = Organization::CompletionSnapshotIndexRequestDto.new(filter_params)
    query_dto = QueryParamsDto.new(query_params)

    snapshots = policy_scope(Organization::CompletionSnapshot).then { |scope| filter_snapshots(scope, filter_dto) }
                                                              .then { |filtered_snapshots| limited_snapshots(filtered_snapshots, query_dto.limit) }
                                                              .order(created_at: :desc)

    render json: Organization::CompletionSnapshotIndexResponseDto.new({ results: snapshots }).to_json
  end

  private

  def completion_snapshot_params
    params.require(:completion_snapshot).permit(:description, completion_snapshot_items: [ :completion_percentage, :item_id ])
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
