# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

ActiveRecord::Base.transaction do
  user = User.create!(
    email: 'test@example.com',
    password: 'password123'
  )

  company = Organization::Company.create!(
    name: "Company Test",
    email: 'contact@testcompany.fr',
    phone: '+33623456789',
    registration_number: "123456789",
    address_street: "12 rue des mouettes",
    address_city: "Biarritz",
    address_zipcode: "64200",
    rcs_city: "REIMS",
    rcs_number: "12345678",
    vat_number: "1234567",
    capital_amount: 12345600
  )

  Organization::CompanyConfig.create!(company: company, payment_term_days: 30, default_vat_rate: 0.2, payment_term_accepted_methods: [ "transfer" ], general_terms_and_conditions: '<h1>CONDITIONS GÉNÉRALES DE VENTE ET DE PRESTATION</h1>')

  Organization::Member.create!(
    user_id: user.id,
    company_id: company.id
  )

  client = Organization::Client.create!(
    id: 2,
    company: company,
    name: "Syndicat de Copropriété ORGEVAL COLOMBIER",
    registration_number: "91811564300010",
    email: "syndic-copro-orgeval-colombier@example.com",
    phone: "+33612345678",
    address_street: "26 Cours De L'exemple",
    address_city: "Reims Cedex",
    address_zipcode: "51723",
    vat_number: "1234"
  )

  result = Organization::Quotes::Create.call(company.id, client.id, {
    name: "Rénovation énergétique de 41 logements 1 et 3 rue Hugues Kraft",
    retention_guarantee_rate: 0.05,
    groups: [
      group_1 = {
        uuid: SecureRandom.uuid,
        name: "Préparation des travaux",
        position: 0
      },
      group_2 = {
        uuid: SecureRandom.uuid,
        name: "Menuiserie en acier",
        position: 1
      },
      group_3 = {
        uuid: SecureRandom.uuid,
        name: "Garde corps en facades",
        position: 2
      },
      group_4 = {
        uuid: SecureRandom.uuid,
        name: "Séparatif de terrasse",
        position: 3
      },
      group_5 = {
        uuid: SecureRandom.uuid,
        name: "Habillages exterieurs",
        position: 4
      },
      group_6 = {
        uuid: SecureRandom.uuid,
        name: "Ouvrages divers",
        position: 5
      },
      group_7 = {
        uuid: SecureRandom.uuid,
        name: "Options",
        position: 6
      }
    ],
    items: [
      # Group 1 items
      {
        name: "Etudes d'execution des ouvrages",
        quantity: 1,
        unit: "ENS",
        unit_price_amount: BigDecimal("1235.00"),
        position: 0,
        tax_rate: "0.20",
        group_uuid: group_1[:uuid]
      },
      {
        name: "Installation de chantier",
        quantity: 1,
        unit: "ENS",
        unit_price_amount: BigDecimal("1345.00"),
        position: 1,
        tax_rate: "0.20",
        group_uuid: group_1[:uuid]
      },
      {
        name: "Travaux de déposes",
        quantity: 1,
        unit: "ENS",
        unit_price_amount: BigDecimal("2000.00"),
        position: 2,
        tax_rate: "0.20",
        group_uuid: group_1[:uuid]
      },
      # Group 2 items
      {
        name: "Ensemble menuiserie des halls en acier compris butée en position ouverte",
        quantity: 2,
        unit: "U",
        unit_price_amount: BigDecimal("7250.00"),
        position: 0,
        tax_rate: "0.20",
        group_uuid: group_2[:uuid]
      },
      {
        name: "Signalisation PMR",
        quantity: 2,
        unit: "ENS",
        unit_price_amount: BigDecimal("223.00"),
        position: 1,
        tax_rate: "0.20",
        group_uuid: group_2[:uuid]
      },
      # Group 3 items
      {
        name: "Gardes corps a remplissage filant passant devant nez de dalle",
        quantity: 100,
        unit: "ML",
        unit_price_amount: BigDecimal("445.00"),
        position: 0,
        tax_rate: "0.20",
        group_uuid: group_3[:uuid]
      },
      {
        name: "Garde corps a remplissage filant type HORIZAL AREAL entre tableau des menuiseries",
        quantity: 27,
        unit: "ML",
        unit_price_amount: BigDecimal("395.00"),
        position: 1,
        tax_rate: "0.20",
        group_uuid: group_3[:uuid]
      },
      {
        name: "Garde corps a remplissage filant type HORIZAL AREAL",
        quantity: 42,
        unit: "ML",
        unit_price_amount: BigDecimal("412.00"),
        position: 2,
        tax_rate: "0.20",
        group_uuid: group_3[:uuid]
      },
      # Group 4 items
      {
        name: "Séparatif de terrasse",
        quantity: 5,
        unit: "U",
        unit_price_amount: BigDecimal("753.00"),
        position: 0,
        tax_rate: "0.20",
        group_uuid: group_4[:uuid]
      },
      # Group 5 items
      {
        name: "Hanillage en toile des moucharabieh des cages",
        quantity: 2,
        unit: "U",
        unit_price_amount: BigDecimal("8960.00"),
        position: 0,
        tax_rate: "0.20",
        group_uuid: group_5[:uuid]
      },
      {
        name: "Cadre d'habillage en toile et bardage metallique des chassis des logements facade nord est",
        quantity: 5,
        unit: "U",
        unit_price_amount: BigDecimal("4144.00"),
        position: 1,
        tax_rate: "0.20",
        group_uuid: group_5[:uuid]
      },
      {
        name: "Cadre d'habillage en tole et bardage métallique des chassis",
        quantity: 20,
        unit: "U",
        unit_price_amount: BigDecimal("3685.00"),
        position: 2,
        tax_rate: "0.20",
        group_uuid: group_5[:uuid]
      },
      # Group 6 items
      {
        name: "Couvertines",
        quantity: 46,
        unit: "ML",
        unit_price_amount: BigDecimal("92.00"),
        position: 0,
        tax_rate: "0.20",
        group_uuid: group_6[:uuid]
      },
      {
        name: "Numéros de voiries",
        quantity: 2,
        unit: "ENS",
        unit_price_amount: BigDecimal("227.00"),
        position: 1,
        tax_rate: "0.20",
        group_uuid: group_6[:uuid]
      },
      # Group 7 items
      {
        name: "Boites aux lettres",
        quantity: 2,
        unit: "ENS",
        unit_price_amount: BigDecimal("2250.00"),
        position: 0,
        tax_rate: "0.20",
        group_uuid: group_7[:uuid]
      },
      {
        name: "Dépose garde corps existant facade arrière",
        quantity: 1,
        unit: "ENS",
        unit_price_amount: BigDecimal("8450.00"),
        position: 1,
        tax_rate: "0.20",
        group_uuid: group_7[:uuid]
      }
    ]
  })

  if result.failure?
    raise "Unable to create quote : #{r.error}"
  end

  quote = result.data

  r = Organization::Quotes::ConvertToDraftOrder.call(quote.id)
  if r.failure?
    raise "Unable to convert quote into order : #{r.error}"
  end
end
