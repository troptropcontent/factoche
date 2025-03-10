module Api
  module V1
    module Organization
      class PrintsController < Api::V1::ApiV1Controller
        include ActionView::Layouts

        skip_before_action :authenticate_user, only: [ :show ]

        # GET /api/v1/organization/prints/completion_snapshot_invoice
        def show
          @locale = :fr
          @snapshot = Organization::CompletionSnapshot.find(params[:id])
          @invoice = @snapshot.invoice
          if @invoice.nil?
            raise Error::UnprocessableEntityError, "No invoice found for this completion snapshot"
          end

          render template: "organization/completion_snapshots/invoice", layout: "print"
        end
      end
    end
  end
end
