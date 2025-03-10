# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

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
  capital_amount_cents: 12345600
)

Organization::CompanyConfig.create!(company: company)

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

project = Organization::Project.create!(
  name: "Rénovation énergétique de 41 logements 1 et 3 rue Hugues Kraft",
  client: client
)

item_groups_params = [
    {
      name: "Préparation des travaux",
      position: 0,
      grouped_items: [
        {
          original_item_uuid: SecureRandom.uuid,
          name: "Etudes d'execution des ouvrages",
          quantity: 1,
          unit: "ENS",
          unit_price_cents: 123500,
          position: 0,
          tax_rate: "0.20"
        },
        {
          original_item_uuid: SecureRandom.uuid,
          name: "Installation de chantier",
          quantity: 1,
          unit: "ENS",
          unit_price_cents: 134500,
          position: 1,
          tax_rate: "0.20"
        },
        {
          original_item_uuid: SecureRandom.uuid,
          name: "Travaux de déposes",
          quantity: 1,
          unit: "ENS",
          unit_price_cents: 200000,
          position: 2,
          tax_rate: "0.20"
        }
      ]
    },
    {
      name: "Menuiserie en acier",
      position: 1,
      grouped_items: [
        {
          original_item_uuid: SecureRandom.uuid,
          name: "Ensemble menuiserie des halls en acier compris butée en position ouverte",
          quantity: 2,
          unit: "U",
          unit_price_cents: 725000,
          position: 0,
          tax_rate: "0.20"
        },
        {
          original_item_uuid: SecureRandom.uuid,
          name: "Signalisation PMR",
          quantity: 2,
          unit: "ENS",
          unit_price_cents: 22300,
          position: 1,
          tax_rate: "0.20"
        }
      ]
    },
    {
      name: "Garde corps en facades",
      position: 2,
      grouped_items: [
        {
          original_item_uuid: SecureRandom.uuid,
          name: "Gardes corps a remplissage filant passant devant nez de dalle",
          quantity: 100,
          unit: "ML",
          unit_price_cents: 44500,
          position: 0,
          tax_rate: "0.20"
        },
        {
          original_item_uuid: SecureRandom.uuid,
          name: "Garde corps a remplissage filant type HORIZAL AREAL entre tableau des menuiseries",
          quantity: 27,
          unit: "ML",
          unit_price_cents: 39500,
          position: 1,
          tax_rate: "0.20"
        },
        {
          original_item_uuid: SecureRandom.uuid,
          name: "Garde corps a remplissage filant type HORIZAL AREAL",
          quantity: 42,
          unit: "ML",
          unit_price_cents: 41200,
          position: 2,
          tax_rate: "0.20"
        }
      ]
    },
    {
      name: "Séparatif de terrasse",
      position: 3,
      grouped_items: [
        {
          original_item_uuid: SecureRandom.uuid,
          name: "Séparatif de terrasse",
          quantity: 5,
          unit: "U",
          unit_price_cents: 75300,
          position: 0,
          tax_rate: "0.20"
        }
      ]
    },
    {
      name: "Habillages exterieurs",
      position: 4,
      grouped_items: [
        {
          original_item_uuid: SecureRandom.uuid,
          name: "Hanillage en toile des moucharabieh des cages",
          quantity: 2,
          unit: "U",
          unit_price_cents: 896000,
          position: 0,
          tax_rate: "0.20"
        },
        {
          original_item_uuid: SecureRandom.uuid,
          name: "Cadre d'habillage en toile et bardage metallique des chassis des logements facade nord est",
          quantity: 5,
          unit: "U",
          unit_price_cents: 414400,
          position: 1,
          tax_rate: "0.20"
        },
        {
          original_item_uuid: SecureRandom.uuid,
          name: "Cadre d'habillage en tole et bardage métallique des chassis",
          quantity: 20,
          unit: "U",
          unit_price_cents: 368500,
          position: 2,
          tax_rate: "0.20"
        }
      ]
    },
    {
      name: "Ouvrages divers",
      position: 5,
      grouped_items: [
        {
          original_item_uuid: SecureRandom.uuid,
          name: "Couvertines",
          quantity: 46,
          unit: "ML",
          unit_price_cents: 9200,
          position: 0,
          tax_rate: "0.20"
        },
        {
          original_item_uuid: SecureRandom.uuid,
          name: "Numéros de voiries",
          quantity: 2,
          unit: "ENS",
          unit_price_cents: 22700,
          position: 1,
          tax_rate: "0.20"
        }
      ]
    },
    {
      name: "Options",
      position: 6,
      grouped_items: [
        {
          original_item_uuid: SecureRandom.uuid,
          name: "Boites aux lettres",
          quantity: 2,
          unit: "ENS",
          unit_price_cents: 225000,
          position: 0,
          tax_rate: "0.20"
        },
        {
          original_item_uuid: SecureRandom.uuid,
          name: "Dépose garde corps existant facade arrière",
          quantity: 1,
          unit: "ENS",
          unit_price_cents: 845000,
          position: 1,
          tax_rate: "0.20"
        }
      ]
    }
  ]

3.times do |index|
  version = Organization::ProjectVersion.create!(project: project, retention_guarantee_rate: 500)

  item_groups_params.each do |p|
    group = version.item_groups.create!(p.slice(:name, :position).merge(project_version: version))
    item_params = p[:grouped_items].map do |grouped_item_param|
      grouped_item_param.merge(project_version: version, item_group: group)
    end
    version.items.create!(item_params)
  end
end
