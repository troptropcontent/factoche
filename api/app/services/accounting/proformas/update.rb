module Accounting
  module Proformas
    class Update
      include ApplicationService
        # 'Updates' a proforma by seting the status to the proforma to 'voided' and by recreating a new draft one with with the updated attributes
        def call(proforma_id, company, client, project, project_version, invoice_items, issue_date = Time.current)
          ActiveRecord::Base.transaction do
            original_proforma = Accounting::Proforma.find(proforma_id)
            # Void current proforma
            original_proforma.update(status: :voided)
            # Create a new proforma to replace the current one
            new_proforma = create_new_proforma!(company, client, project, project_version, invoice_items, issue_date)

            new_proforma
          end
        end

        private

        def create_new_proforma!(company, client, project, project_version, invoice_items, issue_date)
          result = Create.call(company, client, project, project_version, invoice_items, issue_date)

          raise result.error if result.failure?
          result.data
        end
    end
  end
end
