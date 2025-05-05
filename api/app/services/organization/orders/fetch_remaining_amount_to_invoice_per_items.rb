module Organization
  module Orders
    # Fetches and calculates the amount remaining to invoice for each item of an order
    #
    # @param order_id [Integer] The ID of the order to calculate amounts for
    #
    # @param issue_date [Time] Optional date to filter transactions before (defaults to Time.current)
    #
    # @return [Hash] A hash where keys are holder_ids and values are the amount remaining to invoice
    class FetchRemainingAmountToInvoicePerItems
      include ApplicationService

      def call(order_id, issue_date = Time.current)
        @order = Order.find(order_id)
        @version = @order.last_version
        @issue_date = issue_date

        fetch_invoiced_amount!

        compute_remaining_amount_to_invoice_per_items!
      end

      private

      def fetch_invoiced_amount!
        r = FetchInvoicedAmountPerItems.call(@order.id, @issue_date)

        raise r.error if r.failure?

        @invoiced_amounts = r.data
      end

      def compute_remaining_amount_to_invoice_per_items!
        @version.items.each_with_object({}) { |item, object|
          object[item.original_item_uuid] = compute_remaining_amount_for_item(item)
        }
      end

      def compute_remaining_amount_for_item(item)
        item_uuid = item.original_item_uuid
        invoiced_data = @invoiced_amounts[item_uuid]

        total_invoiced = invoiced_data[:invoices_amount]
        total_credits = invoiced_data[:credit_notes_amount]
        item_total = item.quantity * item.unit_price_amount

        item_total - total_invoiced + total_credits
      end
    end
  end
end
