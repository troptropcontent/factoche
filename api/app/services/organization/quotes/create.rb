module Organization
  module Quotes
    class Create
      class << self
        def call(company_id, client_id, params)
          validated_params = validate_params!(params)

          quote, version = ActiveRecord::Base.transaction do
            quote = create_quote!(company_id, client_id, validated_params)
            version = create_version!(quote, validated_params)
            [ quote, version ]
          end

          enqueue_pdf_generation_job!(version)
          ServiceResult.success(quote)
        rescue StandardError => e
          ServiceResult.failure(e)
        end

        private

        def validate_params!(params)
          contract = Organization::Quotes::CreateContract.new
          result = contract.call(params)
          raise Error::UnprocessableEntityError.new(result.errors.to_h) if result.failure?
          result.to_h
        end

        def create_quote!(company_id, client_id, validated_params)
          Organization::Quote.create!(
            company_id: company_id,
            client_id: client_id,
            number: find_next_quote_number!(company_id),
            name: validated_params[:name],
            description: validated_params[:description],
            address_street: validated_params[:address_street],
            address_zipcode: validated_params[:address_zipcode],
            address_city: validated_params[:address_city]
          )
        end

        def create_version!(quote, validated_params)
          result = ProjectVersions::Create.call(quote, validated_params)
          raise Error::UnprocessableEntityError.new("Failed to create project version") if result.failure?

          result.data[:version]
        end

        def find_next_quote_number!(company_id)
          r = Projects::FindNextNumber.call(company_id, Quote)
          raise r.error if r.failure?

          r.data
        end

        def enqueue_pdf_generation_job!(version)
          ProjectVersions::GeneratePdfJob.perform_async({ "project_version_id"=>version.id })
        end
      end
    end
  end
end
