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
  registration_number: "123456789",
  address_street: "12 rue des mouettes",
  address_city: "Biarritz",
  address_zipcode: "64200"
})
Organization::Member.create({ user_id: user.id, company_id: company.id })
client = Organization::Client.create!({ "id"=>2,
"company"=>company,
"name"=>"Syndicat de Copropriété ORGEVAL COLOMBIER",
"registration_number"=>"91811564300010",
"email"=>"syndic-copro-orgeval-colombier@example.com",
"phone"=>"+33612345678",
"address_street"=>"26 Cours De L'exemple",
"address_city"=>"Reims Cedex",
"address_zipcode"=>"51723" })

project = Organization::Project.create!({
  name: "Rénovation énergétique de 41 logements 1 et 3 rue Hugues Kraft",
  client: client
})

build_item_groups_params_proc = ->(version) {
  [
    {
      name: "Préparation des travaux",
      position: 0,
      grouped_items_attributes: [
        { name: "Etudes d'execution des ouvrages", quantity: 1, unit: "ENS", project_version_id: version.id, unit_price_cents: 123500 * (1 + ((version.number - 1) / 100.0)), position: 0 },
        { name: "Installation de chantier", quantity: 1, unit: "ENS", project_version_id: version.id, unit_price_cents: 134500 * (1 + ((version.number - 1) / 100.0)), position: 1 },
        { name: "Travaux de déposes", quantity: 1, unit: "ENS", project_version_id: version.id, unit_price_cents: 200000 * (1 + ((version.number - 1) / 100.0)), position: 2 }
      ]
    },
    {
      name: "Menuiserie en acier",
      position: 1,
      grouped_items_attributes: [
        { name: "Ensemble menuiserie des halls en acier compris butée en position ouverte", quantity: 2, unit: "U", project_version_id: version.id, unit_price_cents: 725000 * (1 + ((version.number - 1) / 100.0)), position: 0 },
        { name: "Signalisation PMR", quantity: 2, unit: "ENS", project_version_id: version.id, unit_price_cents: 22300 * (1 + ((version.number - 1) / 100.0)), position: 1 }
      ]
    },
    {
      name: "Garde corps en facades",
      position: 2,
      grouped_items_attributes: [
        { name: "Gardes corps a remplissage filant passant devant nez de dalle", quantity: 100, unit: "ML", project_version_id: version.id, unit_price_cents: 44500 * (1 + ((version.number - 1) / 100.0)), position: 0 },
        { name: "Garde corps a remplissage filant type HORIZAL AREAL entre tableau des menuiseries", quantity: 27, unit: "ML", project_version_id: version.id, unit_price_cents: 39500 * (1 + ((version.number - 1) / 100.0)), position: 1 },
        { name: "Garde corps a remplissage filant type HORIZAL AREAL", quantity: 42, unit: "ML", project_version_id: version.id, unit_price_cents: 41200 * (1 + ((version.number - 1) / 100.0)), position: 2 }
      ]
    },
    {
      name: "Séparatif de terrasse",
      position: 3,
      grouped_items_attributes: [
        { name: "Séparatif de terrasse", quantity: 5, unit: "U", project_version_id: version.id, unit_price_cents: 75300 * (1 + ((version.number - 1) / 100.0)), position: 0 }
      ]
    },
    {
      name: "Habillages exterieurs",
      position: 4,
      grouped_items_attributes: [
        { name: "Hanillage en toile des moucharabieh des cages", quantity: 2, unit: "U", project_version_id: version.id, unit_price_cents: 896000 * (1 + ((version.number - 1) / 100.0)), position: 0 },
        { name: "Cadre d'habillage en toile et bardage metallique des chassis des logements facade nord est", quantity: 5, unit: "U", project_version_id: version.id, unit_price_cents: 414400 * (1 + ((version.number - 1) / 100.0)), position: 1 },
        { name: "Cadre d'habillage en tole et bardage métallique des chassis", quantity: 20, unit: "U", project_version_id: version.id, unit_price_cents: 368500 * (1 + ((version.number - 1) / 100.0)), position: 2 }
      ]
    },
    {
      name: "Ouvrages divers",
      position: 5,
      grouped_items_attributes: [
        { name: "Couvertines", quantity: 46, unit: "ML", project_version_id: version.id, unit_price_cents: 9200 * (1 + ((version.number - 1) / 100.0)), position: 0 },
        { name: "Numéros de voiries", quantity: 2, unit: "ENS", project_version_id: version.id, unit_price_cents: 22700 * (1 + ((version.number - 1) / 100.0)), position: 1 }
      ]
    },
    {
      name: "Options",
      position: 6,
      grouped_items_attributes: [
        { name: "Boites aux lettres", quantity: 2, unit: "ENS", project_version_id: version.id, unit_price_cents: 225000 * (1 + ((version.number - 1) / 100.0)), position: 0 },
        { name: "Dépose garde corps existant facade arrière", quantity: 1, unit: "ENS", project_version_id: version.id, unit_price_cents: 845000 * (1 + ((version.number - 1) / 100.0)), position: 1 }
      ]
    }
  ]
}

3.times do |index|
  version = Organization::ProjectVersion.create!(project: project, retention_guarantee_rate: 500)
  item_groups_params = build_item_groups_params_proc.call(version)
  item_groups_params.each do |p|
    version.item_groups.create!(p)
  end
end
