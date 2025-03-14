module Accounting
  class GenerateAndAttachPdfToInvoiceJob
    include Sidekiq::Job

    def perform(args)
      validate_args!(args)
      invoice = Invoice.find(args["invoice_id"])

      return if invoice.pdf.attached?

      generate_and_attach_pdf(invoice)
    end

    private

    def validate_args!(args)
      raise Error::UnprocessableEntityError, "Invoice ID is required" if args["invoice_id"].blank?
    end

    def generate_and_attach_pdf(invoice)
      pdf_file = HeadlessBrowserPdfGenerator.call(invoice_url(invoice))
      attach_pdf_to_invoice(invoice, pdf_file)
    ensure
      pdf_file&.close
      pdf_file&.unlink
    end

    def invoice_url(invoice)
      validate_browser_config!

      route_args = [
        invoice.id,
        host: browser_config.fetch(:app_host)
      ]

      if Invoice::PUBLISHED_STATUS.include?(invoice.status)
        Rails.application.routes.url_helpers.accounting_prints_published_invoice_url(*route_args)
      else
        Rails.application.routes.url_helpers.accounting_prints_unpublished_invoice_url(*route_args)
      end
    end

    def attach_pdf_to_invoice(invoice, pdf_file)
      invoice.pdf.attach(
        io: pdf_file,
        filename: "#{invoice.number}.pdf",
        content_type: "application/pdf"
      )
    end

    def browser_config
      @browser_config ||= Rails.configuration.headless_browser
    end

    def validate_browser_config!
      raise Error::UnprocessableEntityError, "Headless browser configuration is missing" if browser_config.nil?
    end
  end
end
