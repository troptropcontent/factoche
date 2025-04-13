module Organization
  module ProjectVersions
    class BuildPdfJobArguments
      class << self
        def call(version)
          version_identifier = Organization::ProjectVersions::BuildVersionNumber.call(version).data

          unless version_identifier
            raise Error::UnprocessableEntityError, "Failed to compute version number"
          end

          ServiceResult.success({
            "url" => find_print_url(version),
            "class_name" => version.class.name,
            "id" => version.id,
            "file_name" => "#{version_identifier}",
            "websocket_channel" => version.project.company.websocket_channel
          })
        rescue StandardError => e
          ServiceResult.failure(e)
        end

        private

        def find_print_url(version)
          case version.project.class.name
          when "Organization::Quote"
            Rails.application.routes.url_helpers.quote_prints_url(version.project.id, version.id, { host: ENV.fetch("PRINT_MICROSERVICE_HOST") })
          when "Organization::DraftOrder"
            Rails.application.routes.url_helpers.draft_order_prints_url(version.project.id, version.id, { host: ENV.fetch("PRINT_MICROSERVICE_HOST") })
          when "Organization::Order"
            Rails.application.routes.url_helpers.order_prints_url(version.project.id, version.id, { host: ENV.fetch("PRINT_MICROSERVICE_HOST") })
          else
            raise Error::UnprocessableEntityError, "Unsupported project type"
          end
        end
      end
    end
  end
end
