class PrintsController < ApplicationController
  include Error::Handler
  include ActionView::Layouts

  before_action :ensure_microservice_env!

  # GET  /prints/quotes/:quote_id/quote_versions/:id
  def quote_version
    @locale = :fr
    @project_type = "quote"
    @project = Organization::Quote.find(params[:quote_id])
    @project_version = @project.versions.find(params[:id])
    @project_version_total_excl_tax_amount = @project_version.items.sum("quantity * unit_price_amount")
    @project_version_vat_amount = @project_version.items.sum("quantity * unit_price_amount * tax_rate")
    render template: "project", layout: "print"
  end

  # GET  /prints/orders/:order_id/order_versions/:id
  def order_version
    @locale = :fr
    @project_type = "order"
    @project = Organization::Order.find(params[:order_id])
    @project_version = @project.versions.find(params[:id])
    @project_version_total_excl_tax_amount = @project_version.items.sum("quantity * unit_price_amount")
    @project_version_vat_amount = @project_version.items.sum("quantity * unit_price_amount * tax_rate")
    render template: "project", layout: "print"
  end

  # GET  /prints/draft_orders/:draft_order_id/draft_order_versions/:id
  def draft_order_version
    @locale = :fr
    @project_type = "draft_order"
    @project = Organization::DraftOrder.find(params[:draft_order_id])
    @project_version = @project.versions.find(params[:id])
    @project_version_total_excl_tax_amount = @project_version.items.sum("quantity * unit_price_amount")
    @project_version_vat_amount = @project_version.items.sum("quantity * unit_price_amount * tax_rate")
    render template: "project", layout: "print"
  end

  private

  def ensure_microservice_env!
    unless ENV.fetch("RAILS_PRINT_MICROSERVICE", nil).present?
      raise Error::UnprocessableEntityError, "This endpoint is only available in the print microservice"
    end
  end
end
