module Accounting
  module FinancialTransactions
    class GenerateAndAttachPdfJob
      include Sidekiq::Job

      def perform(args)
        validate_args!(args)
        financial_transaction = Accounting::FinancialTransaction.find(args["financial_transaction_id"])

        return if financial_transaction.pdf.attached?

        generate_and_attach_pdf(financial_transaction)
      end

      private

      def validate_args!(args)
        raise Error::UnprocessableEntityError, "Financial Transaction ID is required" if args["financial_transaction_id"].blank?
      end

      def generate_and_attach_pdf(financial_transaction)
        url = find_financial_transaction_url!(financial_transaction)
        pdf_file = HeadlessBrowserPdfGenerator.call(url)
        attach_pdf_to_financial_transaction(financial_transaction, pdf_file)
      ensure
        pdf_file&.close
        pdf_file&.unlink
      end

      def find_financial_transaction_url!(financial_transaction)
        validate_browser_config!

        r = Accounting::FinancialTransactions::FindPrintUrl.call(financial_transaction.id)

        raise r.error unless r.success?
        r.data
      end

      def attach_pdf_to_financial_transaction(financial_transaction, pdf_file)
        financial_transaction.pdf.attach(
          io: pdf_file,
          filename: "#{financial_transaction.number}.pdf",
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
end
