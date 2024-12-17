# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user = User.create!(email: 'test@example.com', password: 'password123')
company = Organization::Company.create!({
  name: "Company Test",
  email: 'contact@testcompany.fr',
  phone: '+33623456789',
  address_street: "12 rue des mouettes",
  registration_number: "123456789",
  address_city: "Biarritz",
  address_zipcode: "64200"
})
Organization::Member.create({ user_id: user.id, company_id: company.id })
