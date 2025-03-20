module Organization
  module Projects
    class FindNextNumber
      class << self
        def call(company_id, project_class)
          next_number = project_class.where({ company_id: company_id }).maximum(:number).to_i + 1

          ServiceResult.success(next_number)
        rescue StandardError => e
          ServiceResult.failure(e)
        end

        private
      end
    end
  end
end
