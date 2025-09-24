module Api
  module V1
    module Organization
      class ProformasController < ApiV1Controller
        before_action(except: [ :create, :index ]) { load_and_authorise_resource(class_name: "Accounting::Proforma") }

        # GET    /api/v1/organization/companies/:company_id/proformas
        def index
          proformas = policy_scope(Accounting::Proforma).where(company_id: params[:company_id])
                                                       .then { |proformas| filter_by_order(proformas) }
                                                       .order(:number)

          order_versions = ::Organization::ProjectVersion.where(id: proformas.pluck(:holder_id))

          orders = ::Organization::Order.where(id: order_versions.pluck(:project_id))

          render json: ::Organization::Proformas::IndexDto.new({ results: proformas, meta: { order_versions: order_versions, orders: orders } })
        end

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

        # GET    /api/v1/organization/proformas/:id
        def show
          render json: ::Organization::Proformas::ShowDto.new({ result: @proforma })
        end

        # PATCH  /api/v1/organization/proformas/:id
        # PUT  /api/v1/organization/proformas/:id
        def update
          result = ::Organization::Proformas::Update.call(@proforma.id, proforma_params.to_h)

          if result.failure?
            raise Error::UnprocessableEntityError, "Failed to update proforma: #{result.error}"
          end

          render json: ::Organization::Proformas::ShowDto.new({ result: result.data })
        end

        # DELETE /api/v1/organization/proformas/:id
        def destroy
          result = ::Accounting::Proformas::Void.call(@proforma.id)

          if result.failure?
            raise Error::UnprocessableEntityError, "Failed to void proforma: #{result.error}"
          end

          render json: ::Organization::Proformas::ShowDto.new({ result: result.data })
        end

        # POST   /api/v1/organization/proformas/:id
        def post
          result = ::Accounting::Proformas::Post.call(@proforma.id)

          if result.failure?
            raise Error::UnprocessableEntityError, "Failed to post proforma: #{result.error}"
          end

          render json: ::Organization::Proformas::ShowDto.new({ result: result.data })
        end

        private

        def proforma_params
          params.require(:proforma).permit(:issue_date, invoice_amounts: [ :original_item_uuid, :invoice_amount ])
        end

        def filter_by_order(proformas)
          return proformas unless params[:order_id].present?

          proformas.where(holder_id: ::Organization::ProjectVersion.where(project_id: params[:order_id]).pluck(:id))
        end
      end
    end
  end
end
