module Organization
  class CompanyConfig < ApplicationRecord
    DEFAULT_SETTINGS = {
      "payment_term" => {
        "days" => 30,
        "accepted_methods"=> [ "transfer" ]
      },
      "vat_rate"=> "0.20"
    }.freeze

    belongs_to :company, class_name: "Organization::Company"
  end
end
