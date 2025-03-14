module Accounting
  class GenerateAndAttachPdfToUnpublishedInvoiceJob
    include Sidekiq::Job

    def perform(args)
      @invoice = Invoice.find(args["invoice_id"])

      generate_and_attach_pdf
    end

    private

    def generate_and_attach_pdf
      pdf_file = HeadlessBrowserPdfGenerator.call(invoice_url)
      attach_pdf_to_invoice(pdf_file)
    ensure
      pdf_file&.close
      pdf_file&.unlink
    end

    def invoice_url
      headless_browser_config = Rails.configuration.headless_browser
      if headless_browser_config.nil?
        raise Error::UnprocessableEntityError, "Headless browser configuration is missing"
      end

      Rails.application.routes.url_helpers.accounting_prints_unpublished_invoice_url(
        @invoice.id,
        host: headless_browser_config.fetch(:app_host)
      )
    end

    def attach_pdf_to_invoice(pdf_file)
      @invoice.pdf.attach(
        io: pdf_file,
        filename: "#{@invoice.number}.pdf",
        content_type: "application/pdf"
      )
    end
  end
end
