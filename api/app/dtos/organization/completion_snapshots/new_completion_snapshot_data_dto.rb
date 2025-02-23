module Organization
  module CompletionSnapshots
    class NewCompletionSnapshotDataDto < OpenApiDto
      class DraftInvoice < OpenApiDto
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
          field "invoice_amount", :decimal
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
          field "project_context", :object, subtype: ProjectContext
          field "transaction", :object, subtype: Transaction
        end

        field "payload", :object, subtype: Payload
      end
      class DraftCompletionSnapshot < OpenApiDto
        field "invoice", :object, subtype: DraftInvoice
      end
      field "result", :object, subtype: DraftCompletionSnapshot
    end
  end
end
