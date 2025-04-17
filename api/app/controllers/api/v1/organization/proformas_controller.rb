module Api
  module V1
    module Organization
      class ProformasController < ApiV1Controller
        # POST /api/v1/organization/orders/:order_id/proformas
        def create
          load_and_authorise_resource name: :order, class_name: "::Organization::Order", param_key: :order_id

          order_version = @order.last_version

          result = ::Organization::Proformas::Create.call(order_version.id, proforma_params.to_h)

          if result.failure?
            raise Error::UnprocessableEntityError, "Failed to create a proforma invoice: #{result.error}"
          end

          render json: ::Organization::Proformas::ShowDto.new({ result: result.data })
        end

        private

        def proforma_params
          params.require(:proforma).permit(invoice_amounts: [ :original_item_uuid, :invoice_amount ])
        end
      end
    end
  end
end
