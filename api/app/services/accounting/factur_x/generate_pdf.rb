module Accounting
  module FacturX
    class GeneratePdf
      include ApplicationService

      def call(invoice_id)
          @invoice = Invoice.find(invoice_id)

          unless @invoice.pdf.attached?
            raise Error::UnprocessableEntityError, "The pdf file must have been generated and attached to the invoice to generate the FACTURX pdf"
          end

          @invoice.pdf.open do |pdf_tempfile|
            result = FacturX::GenerateXml.call(@invoice.id)
            xml_tempfile = result.data

            raise result.error if result.failure?

            conn = Faraday.new(url: "http://factur_x:5000") do |f|
              f.request :multipart, content_type: "multipart/form-data"
            end

            payload = {
              pdf: Faraday::Multipart::FilePart.new(pdf_tempfile.path, "application/pdf", "invoice.pdf"),
              xml: Faraday::Multipart::FilePart.new(xml_tempfile.path, "text/xml", "factur-x.xml")
            }

            response = conn.post("/generate_facturx", payload)

            output = Tempfile.new([ "#{@invoice.number}_FACTURX", ".pdf" ])
            output.binmode
            output.write(response.body)
            output.rewind

            output
          end
      end
    end
  end
end
