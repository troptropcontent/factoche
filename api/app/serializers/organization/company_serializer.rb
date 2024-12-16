class Organization::CompanySerializer < Blueprinter::Base
  identifier :id

  fields :name,
         :registration_number,
         :email,
         :phone,
         :address_city,
         :address_street,
         :address_zipcode
end
