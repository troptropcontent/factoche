module Organization
  module ProjectVersions
    class GeneratePdfJob
      include Sidekiq::Job

      def perform(args)
        version = ProjectVersion.find(args.fetch("project_version_id"))
        pdf_job_args = ProjectVersions::BuildPdfJobArguments.call(version).data
        unless pdf_job_args
          raise Error::UnprocessableEntityError, "Failed to build pdf job args"
        end
        GenerateAndAttachPdfToRecordJob.perform_async(pdf_job_args)
      end
    end
  end
end
