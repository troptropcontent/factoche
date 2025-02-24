module Organization
  module CreditNotes
    class BuildPayloadFromInvoice
      class DocumentInfo
        include ActiveModel::AttributeAssignment
        attr_accessor :number,
                      :issue_date,
                      :original_invoice_date,
                      :original_invoice_number
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
                      :seller,
                      :billing_address,
                      :project_context,
                      :transaction
      end

     class << self
      def call(original_invoice, issue_date)
        company, client, project = load_dependencies!(original_invoice)
        Result.new.tap do |result|
          result.assign_attributes(
            document_info: build_document_info_payload(company, original_invoice, issue_date),
            seller: build_seller_payload(company),
            billing_address: build_billing_address_payload(client),
            project_context: build_project_context_payload(original_invoice, project),
            transaction: build_transaction_payload(original_invoice)
          )
        end
      end

      private

      def load_dependencies!(original_invoice)
        original_invoice_snapshot = original_invoice.completion_snapshot
        raise Error::UnprocessableEntityError.new("Completionsnapshot is not defined") if original_invoice_snapshot.nil?
        original_invoice_snapshot_project_version = original_invoice_snapshot.project_version
        raise Error::UnprocessableEntityError.new("Project version is not defined") if original_invoice_snapshot_project_version.nil?
        project = original_invoice_snapshot_project_version.project
        raise Error::UnprocessableEntityError.new("Project is not defined") if project.nil?
        client = project.client
        raise Error::UnprocessableEntityError.new("Client is not defined") if client.nil?
        company = client.company
        raise Error::UnprocessableEntityError.new("Company is not defined") if company.nil?
        company_config = company.config
        raise Error::UnprocessableEntityError.new("CompanyConfig is not defined") if company_config.nil?

        [ company, client, project ]
      end

      def build_document_info_payload(company, invoice, issue_date)
        DocumentInfo.new.tap do |document_info|
          document_info.assign_attributes({
            number: NextAvailableNumber.call(company, issue_date),
            issue_date: issue_date,
            original_invoice_date: invoice.issue_date,
            original_invoice_number: invoice.number
          })
        end
      end

      def build_seller_payload(company)
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

      def build_billing_address_payload(client)
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

      def build_project_context_payload(original_invoice, project)
        ProjectContext.new.assign_attributes(original_invoice.payload.fetch("project_context").merge({
          name: project.name
        }))
      end

      def build_transaction_payload(original_invoice)
        BuildTransactionPayload.call(original_invoice)
      end
     end
    end
  end
end
