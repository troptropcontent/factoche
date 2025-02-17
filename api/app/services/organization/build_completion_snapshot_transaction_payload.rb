module Organization
  class BuildCompletionSnapshotTransactionPayload
    class Payload
      include ActiveModel::AttributeAssignment
      attr_accessor :total_excl_tax_amount
      attr_accessor :tax_rate
      attr_accessor :tax_amount
      attr_accessor :retention_guarantee_amount
      attr_accessor :retention_guarantee_rate
      attr_accessor :items
      attr_accessor :item_groups
    end

    class Item
      include ActiveModel::AttributeAssignment
      attr_accessor :id
      attr_accessor :original_item_uuid
      attr_accessor :name
      attr_accessor :description
      attr_accessor :item_group_id
      attr_accessor :quantity
      attr_accessor :unit
      attr_accessor :unit_price_amount
      attr_accessor :total_amount
      attr_accessor :previously_invoiced_amount
      attr_accessor :completion_percentage
      attr_accessor :completion_amount
      attr_accessor :completion_invoice_amount
    end

    class ItemGroup
      include ActiveModel::AttributeAssignment
      attr_accessor :id
      attr_accessor :name
      attr_accessor :position
      attr_accessor :description
    end

    class << self
      # This service builds a transaction payload for a completion snapshot by:
      # - Computing the total amount excluding tax based on item completion percentages
      # - Calculating tax and retention guarantee amounts
      # - Assembling item and item group details with completion percentages
      # - Tracking previously invoiced amounts per item
      # Used to generate invoices based on project completion progress
      def call(completion_snapshot)
        payload = Payload.new
        payload.items = build_items_payload(completion_snapshot)
        payload.item_groups = build_item_groups_payload(completion_snapshot)
        payload.total_excl_tax_amount = rounded_amount(compute_total_excl_tax_amount(payload.items))
        payload.tax_rate = find_tax_rate(completion_snapshot)
        payload.tax_amount = rounded_amount(payload.total_excl_tax_amount * payload.tax_rate)
        payload.retention_guarantee_rate = find_retention_guarantee_rate(completion_snapshot)
        payload.retention_guarantee_amount = rounded_amount((payload.total_excl_tax_amount + payload.tax_amount) * payload.retention_guarantee_rate)
        payload
      end

      private

      def build_items_payload(new_completion_snapshot)
        new_completion_snapshot.project_version.items.map do |item|
          build_item_payload(
            item,
            new_completion_snapshot
          )
        end
      end

      def build_item_groups_payload(new_completion_snapshot)
        new_completion_snapshot.project_version.item_groups
          .select(:name, :description, :id, :position)
          .map { |item_group|
            ItemGroup.new.tap { |item_group_for_payload|
              item_group_for_payload.assign_attributes(item_group.attributes)
            }
          }
      end

      def indexed_snapshot_items(snapshot)
        snapshot.completion_snapshot_items.includes(:item).index_by { |completion_snapshot|
          completion_snapshot.item.original_item_uuid
        }
      end

      def get_completion_rate(indexed_items, original_item_uuid)
        return BigDecimal("0") unless indexed_items[original_item_uuid]
        BigDecimal(indexed_items[original_item_uuid].completion_percentage.to_s)
      end

      def build_item_payload(item, snapshot)
        Item.new.tap do |item_for_payload|
          item_for_payload.id = item.id
          item_for_payload.original_item_uuid = item.original_item_uuid
          item_for_payload.name = item.name
          item_for_payload.description = item.description
          item_for_payload.item_group_id = item.item_group_id
          item_for_payload.quantity = item.quantity
          item_for_payload.unit = item.unit
          item_for_payload.unit_price_amount = BigDecimal(item.unit_price_cents.to_s) / BigDecimal("100")
          item_for_payload.total_amount = rounded_amount(item_for_payload.unit_price_amount * item_for_payload.quantity)
          item_for_payload.previously_invoiced_amount = compute_previously_invoiced_amount(item.original_item_uuid, snapshot)
          item_for_payload.completion_percentage = get_completion_rate(indexed_snapshot_items(snapshot), item.original_item_uuid)
          item_for_payload.completion_amount = item_for_payload.total_amount * item_for_payload.completion_percentage
          item_for_payload.completion_invoice_amount = rounded_amount(item_for_payload.completion_amount - item_for_payload.previously_invoiced_amount)
        end
      end

      def compute_total_excl_tax_amount(items_from_payload)
        items_from_payload.reduce(0) { |sum, item_from_payload|
          sum + item_from_payload.completion_invoice_amount
        }
      end

      def find_tax_rate(completion_snapshot)
        company_settings = completion_snapshot.project_version.project.client.company.config.settings
        tax_rate_string = company_settings["vat_rate"] || Organization::CompanyConfig::DEFAULT_SETTINGS["vat_rate"]
        BigDecimal(tax_rate_string)
      end

      def find_retention_guarantee_rate(completion_snapshot)
        BigDecimal(completion_snapshot.project_version.retention_guarantee_rate.to_s) / 10000
      end

      def rounded_amount(amount)
        amount.round(2, :half_up)
      end

      def compute_previously_invoiced_amount(original_item_uuid, completion_snapshot)
        amount_from_invoices = 0
        amount_from_credit_notes = 0

        Organization::Invoice
          .joins(
            "JOIN organization_completion_snapshots ON organization_completion_snapshots.invoice_id = organization_accounting_documents.id " \
            "JOIN organization_project_versions ON organization_project_versions.id = organization_completion_snapshots.project_version_id"
          )
          .where("organization_project_versions.project_id = ?", completion_snapshot.project_version.project.id)
          .where("payload -> 'transaction' -> 'items' @> ?", [ { original_item_uuid: original_item_uuid } ].to_json)
          .find_each do |invoice|
            amount_from_invoices =+ invoice.payload["transaction"]["items"].sum do |item|
              item["original_item_uuid"] == original_item_uuid ? BigDecimal(item["amount"]) : BigDecimal("0")
            end
          end

        Organization::CreditNote
          .joins(
            "JOIN organization_completion_snapshots ON organization_completion_snapshots.invoice_id = organization_accounting_documents.id " \
            "JOIN organization_project_versions ON organization_project_versions.id = organization_completion_snapshots.project_version_id"
          )
          .where("organization_project_versions.project_id = ?", completion_snapshot.project_version.project.id)
          .where("payload -> 'transaction' -> 'items' @> ?", [ { original_item_uuid: original_item_uuid } ].to_json)
          .find_each do |invoice|
            amount_from_invoices =+ invoice.payload["transaction"]["items"].sum do |item|
              item["original_item_uuid"] == original_item_uuid ? BigDecimal(item["amount"]) : BigDecimal("0")
            end
          end

        amount_from_invoices - amount_from_credit_notes
      end
    end
  end
end
