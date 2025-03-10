module Api
  module V1
    module Organization
      module Invoices
        class CompletionSnapshotsController < Api::V1::ApiV1Controller
          # POST /api/v1/organization/project_versions/:project_version_id/invoices/completion_snapshot
          def create
            project_version = policy_scope(::Organization::ProjectVersion).find(params[:project_version_id])

            result = ::Organization::Invoices::CompletionSnapshots::Create.call(project_version.id, create_params.to_h)

            if result.failure?
              raise Error::UnprocessableEntityError, "Failed to create completion snapshot invoice: #{result.error}"
            end

            render json: ::Organization::Invoices::CompletionSnapshots::ShowDto.new({ result: result.data })
          end

          private

          def create_params
            params.require(:completion_snapshot).permit(invoice_amounts: [ :original_item_uuid, :invoice_amount ])
          end
        end
      end
    end
  end
end
