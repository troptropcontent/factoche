module Organization
  module ProjectVersions
    class FindNextNumber
      class << self
        def call(project)
          count = project.versions.count
          prefix = project.class.const_get("NUMBER_PREFIX")
          project_identifier = project.id.to_s.rjust(4, "0")
          version_identifier = count.to_s.rjust(4, "0")

          # TODO: Implement logic to find next version number
          ServiceResult.success([ prefix, project_identifier, version_identifier ].join("-"))
        rescue StandardError => e
          ServiceResult.failure(e)
        end

        private
      end
    end
  end
end
