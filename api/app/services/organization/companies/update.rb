module Organization
  module Companies
    module Update
      class << self
        def call(company_id, params)
          company = Company.find(company_id)
          config = CompanyConfig.find_by!({ company_id: company_id })
          validated_params = validate_params!(params)

          company.class.transaction do
            company.update!(validated_params.except(:configs))
            config.update!(validated_params[:configs]) if validated_params[:configs].present?
          end

          ServiceResult.success(company)
        rescue StandardError => e
          ServiceResult.failure("Failed to update company : #{e}, #{e.backtrace}")
        end

        private

        def validate_params!(params)
          contract = UpdateContract.new.call(params)
          unless contract.success?
            raise Error::UnprocessableEntityError, "Invalid update parameters"
          end
          contract.to_h.with_indifferent_access
        end
      end
    end
  end
end
