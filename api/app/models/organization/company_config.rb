module Organization
  class CompanyConfig < ApplicationRecord
    belongs_to :company, class_name: "Organization::Company"
  end
end
