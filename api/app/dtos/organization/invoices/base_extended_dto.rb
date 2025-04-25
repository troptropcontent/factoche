module Organization
  module Invoices
    class BaseExtendedDto < OpenApiDto
      class Line < OpenApiDto
        field "holder_id", :string
        field "excl_tax_amount", :decimal
      end

      class Detail < OpenApiDto
        field "delivery_date", :timestamp
        field "seller_name", :string
        field "seller_registration_number", :string
        field "seller_address_zipcode", :string
        field "seller_address_street", :string
        field "seller_address_city", :string
        field "seller_vat_number", :string
        field "seller_phone", :string
        field "seller_email", :string
        field "client_name", :string
        field "client_registration_number", :string
        field "client_address_zipcode", :string
        field "client_address_street", :string
        field "client_address_city", :string
        field "client_vat_number", :string
        field "client_phone", :string
        field "client_email", :string
        field "delivery_name", :string
        field "delivery_registration_number", :string
        field "delivery_address_zipcode", :string
        field "delivery_address_street", :string
        field "delivery_address_city", :string
        field "delivery_phone", :string
        field "delivery_email", :string
        field "purchase_order_number", :string
        field "due_date", :timestamp
      end

      class Context < OpenApiDto
        class ProjectVersionItem < OpenApiDto
          field "original_item_uuid", :string
          field "group_id", :integer
          field "name", :string
          field "description", :string, required: false
          field "quantity", :integer
          field "unit", :string
          field "unit_price_amount", :decimal
          field "tax_rate", :decimal
          field "previously_billed_amount", :decimal
        end

        class ProjectVersionItemGroup < OpenApiDto
          field "id", :integer
          field "name", :string
          field "description", :string, required: false
        end

        field "project_name", :string
        field "project_version_retention_guarantee_rate", :decimal
        field "project_version_number", :integer
        field "project_version_date", :string
        field "project_total_amount", :decimal
        field "project_total_previously_billed_amount", :decimal
        field "project_version_items", :array, subtype: ProjectVersionItem
        field "project_version_item_groups", :array, subtype: ProjectVersionItemGroup
      end

      field "id", :integer
      field "status", :enum, subtype: [ "posted", "cancelled" ]
      field "number", :string, required: false
      field "updated_at", :timestamp
      field "lines", :array, subtype: Line
      field "detail", :object, subtype: Detail
      field "context", :object, subtype: Context
      field "pdf_url", :string, required: false
      field "total_excl_tax_amount", :decimal
      field "total_including_tax_amount", :decimal
      field "total_excl_retention_guarantee_amount", :decimal
      field "holder_id", :integer
    end
  end
end
