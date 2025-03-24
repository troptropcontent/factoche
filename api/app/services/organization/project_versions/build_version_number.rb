module Organization
  module ProjectVersions
    class BuildVersionNumber
      class << self
        def call(version)
          prefix = version.project.class.const_get("NUMBER_PREFIX")
          project_identifier = version.project.number.to_s.rjust(4, "0")
          version_identifier = version.number.to_s.rjust(4, "0")

          ServiceResult.success([ prefix, project_identifier, version_identifier ].join("-"))
        rescue StandardError => e
          ServiceResult.failure(e)
        end
      end
    end
  end
end
