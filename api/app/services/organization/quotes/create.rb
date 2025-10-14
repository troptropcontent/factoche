module Organization
  module Quotes
    class Create
      include ApplicationService

      def call(company_id, client_id, bank_detail_id, params)
        @company_id = company_id
        @validated_params = validate_params!(params)
        @client_id = client_id
        @bank_detail_id = bank_detail_id

        transaction do
          create_quote!
          create_version!
        end

        enqueue_pdf_generation_job!

        @quote
      end

      private

      def validate_params!(params)
        contract = Organization::Quotes::CreateContract.new
        result = contract.call(params)
        raise Error::UnprocessableEntityError.new(result.errors.to_h) if result.failure?
        result.to_h
      end

      def create_quote!
        @quote = Organization::Quote.create!(
          company_id: @company_id,
          client_id: @client_id,
          bank_detail_id: @bank_detail_id,
          po_number: @validated_params[:po_number],
          number: find_next_quote_number!(@company_id),
          name: @validated_params[:name],
          description: @validated_params[:description],
          address_street: @validated_params[:address_street],
          address_zipcode: @validated_params[:address_zipcode],
          address_city: @validated_params[:address_city]
        )
      end

      def create_version!
        project_version_params = build_project_version_params
        result = ProjectVersions::Create.call(@quote, project_version_params)
        raise result.error if result.failure?

        @version = result.data[:version]
      end

      def find_next_quote_number!(company_id)
        r = Projects::FindNextNumber.call(company_id, Quote)
        raise r.error if r.failure?

        r.data
      end

      def enqueue_pdf_generation_job!
        ProjectVersions::GeneratePdfJob.perform_async({ "project_version_id"=>@version.id })
      end

      def build_project_version_params
        @validated_params.merge({
          general_terms_and_conditions: CompanyConfig.find_by!({ company_id: @company_id }).general_terms_and_conditions
        })
      end
    end
  end
end
