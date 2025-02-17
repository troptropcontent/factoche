class Api::V1::Organization::InvoicesController < Api::V1::ApiV1Controller
  include ActionView::Layouts
  skip_before_action :authenticate_user, only: [ :show ]

  # GET /api/v1/organization/completion_snapshots/:id/invoice
  def show
    @snapshot = Organization::CompletionSnapshot.find(params[:id])
    @item_groups = @snapshot.project_version.item_groups

    render template: "organization/completion_snapshots/invoice", layout: "print"
  end
end
