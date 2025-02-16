module Organization
  class TransitionCompletionSnapshotToInvoiced
    class << self
      # Creates a new invoice record for the given completion snapshot.
      # The invoice will include:
      # - A unique invoice number based on the company's invoice count
      # - Issue date, delivery date and due date based on company payment terms or DEFAULT if not set
      # - Total amount excluding taxes computed from the completion snapshot items
      # - Tax amount based on company VAT rate or or DEFAULT if not set
      # - Retention guarantee amount based on project version settings
      #
      # @param snapshot [Organization::CompletionSnapshot] The completion snapshot to invoice
      # @raise [Error::UnprocessableEntityError] If snapshot is not in draft status or missing required associations
      def call(snapshot, issue_date)
        ensure_snapshot_is_draft!(snapshot)
        company, config = load_dependencies!(snapshot)
        payload = BuildCompletionSnapshotInvoicePayload.call(snapshot)
        ActiveRecord::Base.transaction do
          new_invoice = Organization::Invoice.create({
            number: find_next_invoice_number(company),
            issue_date: issue_date,
            delivery_date: issue_date,
            due_date: compute_due_date(issue_date, config),
            total_excl_tax_amount: payload.transaction.total_excl_tax_amount,
            tax_amount: payload.transaction.tax_amount,
            retention_guarantee_amount: payload.transaction.retention_guarantee_amount,
            payload: payload
          })

          snapshot.update!(invoice: new_invoice)
          [ snapshot, new_invoice ]
        end
      end

      private

      def ensure_snapshot_is_draft!(snapshot)
        if snapshot.status != "draft"
          raise Error::UnprocessableEntityError, "Only draft completion snapshots can be transitioned to invoiced"
        end
      end

      def find_next_invoice_number(company)
        invoice_count = company.invoices.count

        "INV-#{(invoice_count + 1).to_s.rjust(6, "0")}"
      end

      def load_dependencies!(snapshot)
        project_version = snapshot.project_version
        raise Error::UnprocessableEntityError.new("Project version is not defined") if project_version.nil?
        project = project_version.project
        raise Error::UnprocessableEntityError.new("Project is not defined") if project.nil?
        client = project.client
        raise Error::UnprocessableEntityError.new("Client is not defined") if client.nil?
        company = client.company
        raise Error::UnprocessableEntityError.new("Company is not defined") if company.nil?
        config = company.config
        raise Error::UnprocessableEntityError.new("CompnyConfig is not defined") if config.nil?
        [ company, config, project_version ]
      end

      def compute_due_date(timestamp, config)
        days = config.settings.dig("payment_term", "days") ||
          Organization::CompanyConfig::DEFAULT_SETTINGS.fetch("payment_term").fetch("days")

        timestamp.advance(days: days)
      end

      def compute_total_excluding_taxes(snapshot)
        Organization::ComputeCompletionSnapshotTotal.call(snapshot)
      end

      def compute_taxes_amount!(total_excluding_taxes_amount, config)
        taxes_percentage_string = config.settings.dig("vat_rate") ||
          Organization::CompanyConfig::DEFAULT_SETTINGS.fetch("vat_rate")

        total_excluding_taxes_amount * BigDecimal(taxes_percentage_string)
      end

      def compute_retention_guarantee_amount(total_excluding_taxes_amount, tax_amount, project_version)
        (total_excluding_taxes_amount + tax_amount) * project_version.retention_guarantee_rate / 100
      end
    end
  end
end
