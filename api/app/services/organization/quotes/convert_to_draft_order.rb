module Organization
  module Quotes
    class ConvertToDraftOrder
      class << self
        def call(quote_id)
          quote = Quote.find(quote_id)

          ensure_quote_have_not_been_converted_already!(quote)

          draft_order, draft_order_version = ActiveRecord::Base.transaction do
            draft_order, draft_order_version = duplicate_quote!(quote)

            quote.update!(posted: true, posted_at: Time.current())

            [ draft_order, draft_order_version ]
          end

          trigger_pdf_generation_job(draft_order_version)

          ServiceResult.success(draft_order)
        rescue StandardError => e
          ServiceResult.failure("Failed to convert quote to draft order: #{e.message}, #{e.backtrace[0]}")
        end

        private

        def trigger_pdf_generation_job(draft_order_version)
          ProjectVersions::GeneratePdfJob.perform_async({ "project_version_id"=>draft_order_version.id })
        end

        def duplicate_quote!(quote)
          r = Projects::Duplicate.call(quote, DraftOrder)
          raise r.error if r.failure?

          [ r.data[:new_project], r.data[:new_project_version] ]
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
