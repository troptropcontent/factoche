module Accounting
  module FinancialTransactions
    class GenerateAndAttachFacturXJob
      include Sidekiq::Job

      def perform(args)
        validate_args!(args)
        @financial_transaction = Accounting::FinancialTransaction.find(args["financial_transaction_id"])

        return if  @financial_transaction.factur_x.attached?

        generate_and_attach_pdf!
      end

      private

      def validate_args!(args)
        raise Error::UnprocessableEntityError, "Financial Transaction ID is required" if args["financial_transaction_id"].blank?
      end

      def generate_and_attach_pdf!
        result = FacturX::GeneratePdf.call(@financial_transaction.id)
        pdf_file = result.data

        raise result.error if result.failure?

        @financial_transaction.factur_x.attach(
          io: pdf_file,
          filename: "#{@financial_transaction.number}_FACTURX.pdf",
          content_type: "application/pdf"
        )
      end
    end
  end
end
