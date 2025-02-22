module Organization
  module CreditNotes
    class BuildTransactionPayload
      class Result
        include ActiveModel::AttributeAssignment
        attr_accessor :total_excl_tax_amount,
                     :tax_rate,
                     :tax_amount,
                     :retention_guarantee_amount,
                     :retention_guarantee_rate,
                     :items,
                     :item_groups,
                     :credit_note_total_amount
      end

      class Item
        include ActiveModel::AttributeAssignment
        attr_accessor :id,
                     :original_item_uuid,
                     :name,
                     :description,
                     :item_group_id,
                     :quantity,
                     :unit,
                     :unit_price_amount,
                     :credit_note_amount
      end

      class << self
        def call(original_invoice)
          raise ArgumentError, "Original invoice is required" if original_invoice.nil?
          raise ArgumentError, "Invalid invoice payload" unless valid_invoice_payload?(original_invoice)

          Result.new.tap do |result|
            result.assign_attributes(
              original_invoice.payload.fetch("transaction")
                .except("invoice_total_amount")
                .merge(
                  items: build_items_payload(original_invoice),
                  credit_note_total_amount: original_invoice.payload.fetch("transaction").fetch("invoice_total_amount")
                )
            )
          end
        rescue KeyError => e
          raise ArgumentError, "Missing required field: #{e.message}"
        rescue ArgumentError => e
          raise
        rescue StandardError => e
          raise ArgumentError, "Failed to build transaction payload: #{e.message}"
        end

        private

        def valid_invoice_payload?(invoice)
          invoice.payload.is_a?(Hash) &&
            invoice.payload["transaction"].is_a?(Hash) &&
            invoice.payload.dig("transaction", "items").is_a?(Array)
        end

        def build_items_payload(original_invoice)
          original_invoice.payload.dig("transaction", "items").map do |original_invoice_payload_item|
            build_item_payload(original_invoice_payload_item)
          end
        end

        def build_item_payload(original_invoice_payload_item)
          Item.new.tap do |payload_item|
            payload_item.assign_attributes(
              id: original_invoice_payload_item.fetch("id"),
              original_item_uuid: original_invoice_payload_item.fetch("original_item_uuid"),
              name: original_invoice_payload_item.fetch("name"),
              description: original_invoice_payload_item.fetch("description"),
              item_group_id: original_invoice_payload_item.fetch("item_group_id"),
              quantity: original_invoice_payload_item.fetch("quantity"),
              unit: original_invoice_payload_item.fetch("unit"),
              unit_price_amount: original_invoice_payload_item.fetch("unit_price_amount"),
              credit_note_amount: original_invoice_payload_item.fetch("completion_invoice_amount")
            )
          end
        end
      end
    end
  end
end
