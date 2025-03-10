class Api::V1::Organization::InvoicesController < Api::V1::ApiV1Controller
  # GET /api/v1/organization/projects/:project_id/invoices
  def index
    project = policy_scope(Organization::Project).find(params[:project_id])

    invoices = Accounting::CompletionSnapshotInvoice
      .joins(:lines)
      .select(
        "accounting_financial_transactions.*, " \
        "SUM(accounting_financial_transaction_lines.quantity * " \
        "accounting_financial_transaction_lines.unit_price_amount) as total_amount"
      )
      .where(holder_id: project.versions.pluck(:id))
      .group("accounting_financial_transactions.id")

    render json: ::Organization::Invoices::IndexDto.new({ results: invoices })
  end
end
