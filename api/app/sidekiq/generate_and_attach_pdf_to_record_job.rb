
class GenerateAndAttachPdfToRecordJob
  include Sidekiq::Job

  def perform(args)
    url = args.fetch("url")
    klass = args.fetch("class_name").constantize
    websocket_channel_name = args["websocket_channel"]

    raise Error::UnprocessableEntityError, "Class must inherit from ActiveRecord::Base" unless klass < ActiveRecord::Base

    record = klass.find(args.fetch("id"))
    file_name = args.fetch("file_name")

    generate_and_attach_pdf(record, url, file_name, websocket_channel_name)
  end

  private

  def generate_and_attach_pdf(record, url, file_name, websocket_channel_name)
    pdf_file = HeadlessBrowserPdfGenerator.call(url)
    attach_pdf_to_record(record, pdf_file, file_name)
    broadcast_to_channel(websocket_channel_name, record) if websocket_channel_name
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

  def broadcast_to_channel(websocket_channel_name, record)
    ActionCable.server.broadcast(websocket_channel_name, {
      "type" => "PDF_GENERATED",
      "data" => { "record_class"=> record.class.name.demodulize, "record_id"=> record.id }
      })
  end
end
