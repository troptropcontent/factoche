module Organization
  module Quotes
    class ConvertToDraftOrder
      class << self
        def call(quote_id)
          quote = Quote.find(quote_id)

          ensure_quote_have_not_been_converted_already!(quote)

          ActiveRecord::Base.transaction do
            draft_order = duplicate_quote!(quote)

            quote.update!(posted: true, posted_at: Time.current())

            ServiceResult.success(draft_order)
          end
        rescue StandardError => e
          ServiceResult.failure("Failed to convert quote to draft order: #{e.message}, #{e.backtrace[0]}")
        end

        private

        def duplicate_quote!(quote)
          r = Projects::Duplicate.call(quote, DraftOrder)
          raise r.error if r.failure?

          r.data[:new_project]
        end

        def ensure_quote_have_not_been_converted_already!(quote)
          # quote.posted? should be enought but we never know
          is_converted = quote.posted? || quote.draft_orders.any?
          raise Error::UnprocessableEntityError, "Quote has already been converted to an draft order" if is_converted
        end
      end
    end
  end
end
