module Organization
  class BuildCompletionSnapshotInvoicePayload
    class DocumentInfo
      include ActiveModel::AttributeAssignment
      attr_accessor :number,
                    :issue_date,
                    :delivery_date,
                    :due_date
    end

    class PaymentTerm
      include ActiveModel::AttributeAssignment
      attr_accessor :days, :accepted_methods
    end

    class Address
      include ActiveModel::AttributeAssignment
      attr_accessor :city, :street, :zip
    end

    class Seller
      include ActiveModel::AttributeAssignment
      attr_accessor :name,
                    :address,
                    :phone,
                    :siret,
                    :legal_form,
                    :capital_amount,
                    :vat_number,
                    :rcs_city,
                    :rcs_number
    end

    class BillingAddress
      include ActiveModel::AttributeAssignment
      attr_accessor :name, :address
    end

    class DeliveryAddress
      include ActiveModel::AttributeAssignment
      attr_accessor :name, :address
    end

    class ProjectVersion
      include ActiveModel::AttributeAssignment
      attr_accessor :date,
                    :number
    end

    class ProjectContext
      include ActiveModel::AttributeAssignment
      attr_accessor :name,
                    :version,
                    :total_amount,
                    :previously_billed_amount,
                    :remaining_amount
    end

    class Result
      include ActiveModel::AttributeAssignment
      attr_accessor :document_info,
                    :payment_term,
                    :seller,
                    :billing_address,
                    :delivery_address,
                    :project_context,
                    :transaction
    end

    class << self
      def call(snapshot, issue_date)
        project_version, project, client, company, company_config = load_dependencies!(snapshot)

        Result.new.tap do |result|
          result.assign_attributes(
            document_info: build_document_info(snapshot, company, company_config, issue_date),
            payment_term: payment_term(company_config),
            seller: seller(company),
            billing_address: billing_address(client),
            delivery_address: delivery_address(client),
            project_context: project_context(project, project_version, issue_date),
            transaction: build_transaction_payload(snapshot, issue_date)
          )
        end
      end

      private

      def load_dependencies!(snapshot)
        project_version = snapshot.project_version
        raise Error::UnprocessableEntityError.new("Project version is not defined") if project_version.nil?
        project = project_version.project
        raise Error::UnprocessableEntityError.new("Project is not defined") if project.nil?
        client = project.client
        raise Error::UnprocessableEntityError.new("Client is not defined") if client.nil?
        company = client.company
        raise Error::UnprocessableEntityError.new("Company is not defined") if company.nil?
        company_config = company.config
        raise Error::UnprocessableEntityError.new("CompanyConfig is not defined") if company_config.nil?

        [ project_version, project, client, company, company_config ]
      end


      def payment_term(config)
        PaymentTerm.new.tap { |p|
          p.assign_attributes(
            days: config.settings.dig("payment_term", "days") || CompanyConfig::DEFAULT_SETTINGS.dig("payment_term", "days"),
            accepted_methods: config.settings.dig("payment_term", "accepted_methods") || CompanyConfig::DEFAULT_SETTINGS.dig("payment_term", "accepted_methods")
          )
        }
      end


      def seller(company)
        Seller.new.tap { |s|
          s.assign_attributes(
            name: company.name,
            phone: company.phone,
            siret: company.registration_number,
            rcs_city: company.rcs_city,
            rcs_number: company.rcs_number,
            vat_number: company.vat_number,
            legal_form: company.legal_form,
            capital_amount: BigDecimal(company.capital_amount_cents) / BigDecimal("100"),
            address: Address.new.tap { |a|
              a.assign_attributes(
                city: company.address_city,
                street: company.address_street,
                zip: company.address_zipcode
              )
            }
          )
        }
      end


      def billing_address(client)
        BillingAddress.new.tap { |b|
          b.assign_attributes(
            name: client.name,
            address: Address.new.tap { |a|
              a.assign_attributes(
                city: client.address_city,
                street: client.address_street,
                zip: client.address_zipcode
              )
            }
          )
        }
      end


      def delivery_address(client)
        DeliveryAddress.new.tap { |d|
          d.assign_attributes(
            name: client.name,
            address: Address.new.tap { |a|
              a.assign_attributes(
                city: client.address_city,
                street: client.address_street,
                zip: client.address_zipcode
              )
            }
          )
        }
      end


      def project_context(project, project_version, issue_date)
        context = ProjectContext.new
        context.name = project.name
        context.version = ProjectVersion.new.tap { |v| v.assign_attributes(number: project_version.number, date: project_version.created_at) }
        context.total_amount = BigDecimal(project_version.items.sum("quantity * unit_price_cents").to_i) / 100
        context.previously_billed_amount = project.invoices.where(issue_date: ...issue_date).sum("total_excl_tax_amount") - project.credit_notes.where(issue_date: ...issue_date).sum("total_excl_tax_amount")
        context.remaining_amount = context.total_amount - context.previously_billed_amount
        context
      end

      def build_transaction_payload(completion_snapshot, issue_date)
        BuildCompletionSnapshotTransactionPayload.call(completion_snapshot, issue_date)
      end

      def build_document_info(snapshot, company, company_config, issue_date)
        DocumentInfo.new.tap { |document_info|
          document_info.assign_attributes({
            number: snapshot&.invoice&.number || FindNextAvailableInvoiceNumber.call(company),
            issue_date: issue_date,
            delivery_date: issue_date,
            due_date: compute_due_date(issue_date, company_config)
          })
        }
      end

      def compute_due_date(issue_date, config)
        days = config.settings.dig("payment_term", "days") ||
          Organization::CompanyConfig::DEFAULT_SETTINGS.fetch("payment_term").fetch("days")

        issue_date.advance(days: days)
      end
    end
  end
end
