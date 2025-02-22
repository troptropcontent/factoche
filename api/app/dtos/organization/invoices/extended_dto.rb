module Organization
  module Invoices
    class ExtendedDto < OpenApiDto
      class DocumentInfo < OpenApiDto
        field "number", :string
        field "issue_date", :timestamp
        field "delivery_date", :timestamp
        field "due_date", :timestamp
      end

      class PaymentTerm < OpenApiDto
        field "days", :integer
        # field "accepted_methods", :array, subtype: :string
      end

      class Address < OpenApiDto
        field "city", :string
        field "street", :string
        field "zip", :string
      end

      class Seller < OpenApiDto
        field "name", :string
        field "address", :object, subtype: Address
        field "phone", :string
        field "siret", :string
        field "legal_form", :string
        field "capital_amount", :decimal
        field "vat_number", :string
        field "rcs_city", :string
        field "rcs_number", :string
      end

      class BillingAddress < OpenApiDto
        field "name", :string
        field "address", :object, subtype: Address
      end

      class DeliveryAddress < OpenApiDto
        field "name", :string
        field "address", :object, subtype: Address
      end

      class ProjectVersion < OpenApiDto
        field "date", :timestamp
        field "number", :integer
      end

      class ProjectContext < OpenApiDto
        field "name", :string
        field "version", :object, subtype: ProjectVersion
        field "total_amount", :decimal
        field "previously_billed_amount", :decimal
        field "remaining_amount", :decimal
      end

      class Item < OpenApiDto
        field "id", :integer
        field "original_item_uuid", :string
        field "name", :string
        field "description", :string, required: false
        field "item_group_id", :integer
        field "quantity", :integer
        field "unit", :string
        field "unit_price_amount", :decimal
        field "total_amount", :decimal
        field "previously_invoiced_amount", :decimal
        field "completion_percentage", :decimal
        field "completion_amount", :decimal
        field "completion_invoice_amount", :decimal
      end

      class ItemGroup < OpenApiDto
        field "id", :integer
        field "name", :string
        field "position", :integer
        field "description", :string, required: false
      end

      class Transaction < OpenApiDto
        field "total_excl_tax_amount", :decimal
        field "tax_rate", :decimal
        field "tax_amount", :decimal
        field "retention_guarantee_amount", :decimal
        field "retention_guarantee_rate", :decimal
        field "items", :array, subtype: Item
        field "item_groups", :array, subtype: ItemGroup
        field "invoice_total_amount", :decimal
      end

      class Payload < OpenApiDto
        field "document_info", :object, subtype: DocumentInfo
        field "payment_term", :object, subtype: PaymentTerm
        field "seller", :object, subtype: Seller
        field "billing_address", :object, subtype: BillingAddress
        field "delivery_address", :object, subtype: DeliveryAddress
        field "project_context", :object, subtype: ProjectContext
        field "transaction", :object, subtype: Transaction
      end

      field "pdf_url", :string, required: false
      field "payload", :object, subtype: Payload
    end
  end
end
