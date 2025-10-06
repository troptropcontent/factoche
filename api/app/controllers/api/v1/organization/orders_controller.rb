module Api
  module V1
    module Organization
      class OrdersController < Api::V1::ApiV1Controller
        before_action(only: [ :update ]) { load_and_authorise_resource }

        # GET    /api/v1/organization/companies/:company_id/orders
        def index
          orders = policy_scope(::Organization::Project).where(type: "Organization::Order", client: { company_id: params[:company_id] })
          render json: ::Organization::Projects::Orders::IndexDto.new({ results: orders }).to_json
        end

        # GET    /api/v1/organization/orders/:id
        def show
          order = policy_scope(::Organization::Project).where(type: "Organization::Order").find(params[:id])
          render json: ::Organization::Projects::Orders::ShowDto.new({ result: order }).to_json
        end

        # PUT    /api/v1/organization/orders/:id
        def update
          result = ::Organization::Orders::Update.call(@order.id, update_order_params.to_h)
          raise result.error if result.failure?

          render json: ::Organization::Projects::Orders::ShowDto.new({ result: result.data }).to_json
        end

        # GET  /api/v1/organization/orders/:id/invoiced_items
        def invoiced_items
          order = policy_scope(::Organization::Project).where(type: "Organization::Order").find(params[:id])

          result = ::Organization::Orders::FetchInvoicedAmountPerItems.call(order.id)

          raise Error::UnprocessableEntityError.new(result.error) unless result.success?

          items = ::Organization::Item.where(project_version_id: order.versions.pluck(:id)).order(:original_item_uuid)
          results = items.map do |item|
            {
              original_item_uuid: item.original_item_uuid,
              invoiced_amount: result.data[item.original_item_uuid][:invoices_amount] - result.data[item.original_item_uuid][:credit_notes_amount]
            }
          end

          render json: ::Organization::Projects::Orders::InvoicedItemsDto.new({ results: results }).to_json
        end

        private

        def update_order_params
          params.require(:order).permit(
            :name,
            :description,
            :retention_guarantee_rate,
            :bank_detail_id,
            :po_number,
            :address_street,
            :address_zipcode,
            :address_city,
            new_items: [
              :group_uuid,
              :name,
              :description,
              :quantity,
              :unit,
              :unit_price_amount,
              :position,
              :tax_rate
            ],
            updated_items: [
              :original_item_uuid,
              :group_uuid,
              :quantity,
              :unit_price_amount,
              :position,
              :tax_rate
            ],
            groups: [
              :uuid,
              :name,
              :description,
              :position
            ]
          )
        end
      end
    end
  end
end
