module Accounting
  module Proformas
    class Update
      include ApplicationService

      class Contract < Dry::Validation::Contract
        params do
          required(:proforma_id).filled(:integer)
          required(:company).hash(CompanySchema)
          required(:client).hash(ClientSchema)
          required(:project_version).hash(ProjectVersionSchema)
          required(:project).hash(ProjectSchema)
          required(:snapshot_number).filled(:integer)
          required(:new_invoice_items).array(:hash) do
            required(:original_item_uuid).filled(:string)
            required(:invoice_amount).filled(:decimal)
          end
          optional(:issue_date).filled(:time)
        end
      end

      def call(args)
        validated_args = validate!(args, Contract)

        ActiveRecord::Base.transaction do
          original_proforma = Accounting::Proforma.find(args[:proforma_id])

          # Void current proforma
          original_proforma.update(status: :voided)

          # Create a new proforma to replace the current one
          new_proforma = create_new_proforma!(validated_args)

          new_proforma
        end
      end

      private

      def create_new_proforma!(args)
        result = Create.call(args)

        raise result.error if result.failure?

        result.data
      end
    end
  end
end
