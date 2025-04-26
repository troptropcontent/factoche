module Api
  module V1
    module Organization
      class DashboardsController < Api::V1::ApiV1Controller
        before_action { load_and_authorise_resource(name: :company, param_key: "company_id", class_name: "Organization::Company") }

        # GET  /api/v1/organization/companies/:company_id/dashboard
        def show
          result = ::Organization::Dashboards::FetchData.call(
            company_id: @company.id,
            end_date: Time.current,
            websocket_channel_id: @company.websocket_channel
          )

          raise result.error if result.failure?

          render json: ::Organization::Dashboards::ShowDto.new({ result: result.data }).to_json
        end
      end
    end
  end
end
