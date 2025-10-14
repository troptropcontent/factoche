class PrintsController < ApplicationController
  include Error::Handler
  include ActionView::Layouts

  before_action :require_print_token!, unless: -> { Rails.env.development? }

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

  def require_print_token!
    token = params[:token]
    raise Error::ForbiddenError, "Forbiden" unless token.present?

    secret = ENV.fetch("PRINT_TOKEN_SECRET", nil)
    raise Error::UnprocessableEntityError, "PRINT_TOKEN_SECRET seems not to be set" unless secret.present?

    begin
      JwtAuth.decode_token(token, secret)
    rescue JWT::ExpiredSignature
      raise Error::ForbiddenError, "Expired token"
    rescue JWT::DecodeError
      raise Error::ForbiddenError, "Invalid token"
    end
  end
end
