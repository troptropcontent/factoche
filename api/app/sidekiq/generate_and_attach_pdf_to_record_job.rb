
class GenerateAndAttachPdfToRecordJob
  include Sidekiq::Job

  def perform(args)
    url = args.fetch("url")
    klass = args.fetch("class_name").constantize

    raise Error::UnprocessableEntityError, "Class must inherit from ActiveRecord::Base" unless klass < ActiveRecord::Base

    record = klass.find(args.fetch("id"))
    file_name = args.fetch("file_name")

    generate_and_attach_pdf(record, url, file_name)
  end

  private

  def generate_and_attach_pdf(record, url, file_name)
    pdf_file = HeadlessBrowserPdfGenerator.call(url)
    attach_pdf_to_record(record, pdf_file, file_name)
  ensure
    pdf_file&.close
    pdf_file&.unlink
  end

  def attach_pdf_to_record(record, pdf_file, file_name)
    record.pdf.attach(
      io: pdf_file,
      filename: "#{file_name}.pdf",
      content_type: "application/pdf"
    )
  end
end
