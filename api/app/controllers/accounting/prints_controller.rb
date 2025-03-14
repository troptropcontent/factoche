module Accounting
  class PrintsController < ApplicationController
    include Error::Handler
    include ActionView::Layouts

    before_action :ensure_microservice_env!

    # # GET /api/v1/organization/prints/published_invoice/:id
    # def published_invoice
    #   @locale = :fr
    #   @invoice = Accounting::Invoice.find_by(id: params[:id])
    #   if @invoice.nil?
    #     raise Error::UnprocessableEntityError, "No invoice found for this id"
    #   end

    #   unless @invoice.posted? || @invoice.cancelled?
    #     raise Error::UnprocessableEntityError, "Invoice must be in posted or cancell status"
    #   end

    #   render template: "accounting/invoice", layout: "print"
    # end


    # GET /accounting/prints/unpublished_invoices/:id
    def unpublished_invoice
      @proforma = true
      @locale = :fr
      @invoice = Accounting::Invoice.find_by(id: params[:id])
      if @invoice.nil?
        raise Error::UnprocessableEntityError, "No invoice found for this id"
      end

      unless @invoice.draft? || @invoice.voided?
        raise Error::UnprocessableEntityError, "Invoice must be in draft or voided status"
      end

      render template: "accounting/invoice", layout: "print"
    end

    private

    def ensure_microservice_env!
      unless ENV.fetch("RAILS_PRINT_MICROSERVICE", nil).present?
        raise Error::UnprocessableEntityError, "This endpoint is only available in the print microservice"
      end
    end
  end
end
