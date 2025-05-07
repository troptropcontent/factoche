module Api
  module V1
    module Organization
      class PaymentsController < Api::V1::ApiV1Controller
        # POST    /api/v1/organization/payments
        def create
          load_and_authorise_resource name: :invoice, class_name: "::Accounting::Invoice", id: params.require(:invoice_id)

          result = Accounting::Payments::Create.call(@invoice.id)

          if result.failure?
            raise Error::UnprocessableEntityError, "Failed to create the payment: #{result.error}"
          end

          render json: Accounting::Payments::ShowDto.new(result: result.data), status: :created
        end

        private

        def payment_params
          params.require(:payment).permit(:invoice_id)
        end
      end
    end
  end
end
