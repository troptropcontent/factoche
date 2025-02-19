class Organization::GenerateAndAttachPdfToInvoiceJob
  include Sidekiq::Job

  def perform(args)
    @completion_snapshot = Organization::CompletionSnapshot.find(args["completion_snapshot_id"])
    @invoice = @completion_snapshot.invoice

    validate_invoice!
    generate_and_attach_pdf
  end

  private

  def validate_invoice!
    return if @invoice.present?
    raise Error::UnprocessableEntityError, "No invoice exists for this completion snapshot"
  end

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

    Rails.application.routes.url_helpers.api_v1_organization_invoice_url(
      @completion_snapshot,
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
