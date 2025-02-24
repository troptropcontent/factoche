module Organization
  module CreditNotes
    class ExtendedDto < OpenApiDto
      class DocumentInfo < OpenApiDto
        field "number", :string
        field "issue_date", :timestamp
        field "original_invoice_date", :timestamp
        field "original_invoice_number", :string
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
        field "credit_note_amount", :decimal
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
        field "total_incl_tax_amount", :decimal
        field "items", :array, subtype: Item
        field "item_groups", :array, subtype: ItemGroup
        field "credit_note_total_amount", :decimal
      end

      class Payload < OpenApiDto
        field "document_info", :object, subtype: DocumentInfo
        field "seller", :object, subtype: Seller
        field "billing_address", :object, subtype: BillingAddress
        field "project_context", :object, subtype: ProjectContext
        field "transaction", :object, subtype: Transaction
      end

      field "pdf_url", :string, required: false
      field "payload", :object, subtype: Payload
      field "status", :enum, subtype: [ "draft", "published" ]
    end
  end
end
