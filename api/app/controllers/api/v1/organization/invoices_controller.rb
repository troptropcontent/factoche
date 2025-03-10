class Api::V1::Organization::InvoicesController < Api::V1::ApiV1Controller
  # GET /api/v1/organization/projects/:project_id/invoices
  def index
    project = policy_scope(Organization::Project).find(params[:project_id])

    invoices = Accounting::FinancialTransaction.where(holder_id: project.versions.pluck(:id)).where("type LIKE '%#{Accounting::FinancialTransaction::InvoiceType}'")

    render json: ::Organization::Invoices::IndexDto.new({ results: invoices })
  end
end
