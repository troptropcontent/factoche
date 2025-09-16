module Accounting
  class PrintsController < ApplicationController
    include Error::Handler
    include ActionView::Layouts

    before_action :require_token!, unless: -> { Rails.env.development? }

    # GET /accounting/prints/published_invoices/:id
    def published_invoice
      @proforma = false
      @locale = :fr
      @invoice = Accounting::Invoice.find_by(id: params[:id])
      if @invoice.nil?
        raise Error::UnprocessableEntityError, "No invoice found for this id"
      end

      render template: "accounting/invoice", layout: "print"
    end


    # GET /accounting/prints/unpublished_invoices/:id
    def unpublished_invoice
      @proforma = true
      @locale = :fr
      @invoice = Accounting::Proforma.find_by(id: params[:id])

      if @invoice.nil?
        raise Error::UnprocessableEntityError, "No invoice found for this id"
      end

      render template: "accounting/invoice", layout: "print"
    end

    # GET /accounting/prints/credit_notes/:id
    def credit_note
      @locale = :fr
      @credit_note = Accounting::CreditNote.find_by(id: params[:id])
      if @credit_note.nil?
        raise Error::UnprocessableEntityError, "No credit_note found for this id"
      end

      unless @credit_note.posted?
        raise Error::UnprocessableEntityError, "CreditNote must be posted"
      end

      # TODO : return the credit note print
      @invoice = @credit_note
      render template: "accounting/invoice", layout: "print"
    end

    private

    def require_token!
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
end
