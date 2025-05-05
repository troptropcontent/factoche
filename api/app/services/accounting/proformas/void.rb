module Accounting
  module Proformas
    class Void
      include ApplicationService

      def call(proforma_id)
        raise Error::UnprocessableEntityError, "Proforma ID is required" if proforma_id.blank?

        @proforma = Accounting::Proforma.find(proforma_id)

        ensure_proforma_is_draft!

        @proforma.update!(status: :voided)

        @proforma
      end

      private

      def ensure_proforma_is_draft!
        return if @proforma.draft?

        raise Error::UnprocessableEntityError, "Cannot void a proforma that is not in draft status"
      end
    end
  end
end
