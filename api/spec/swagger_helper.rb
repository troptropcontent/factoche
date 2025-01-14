# frozen_string_literal: true

require 'rails_helper'

Dir[Rails.root.join('app/dtos/**/*.rb')].each { |file| require file }

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      components: {
        schemas: {
          client: {
            type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 registration_number: { type: :string },
                 email: { type: :string },
                 phone: { type: :string },
                 address_city: { type: :string },
                 address_street: { type: :string },
                 address_zipcode: { type: :string }
               },
               required: [ 'id', 'name', 'registration_number', 'email', 'phone', 'address_city', 'address_street', 'address_zipcode' ]
          },
          create_project_with_item_groups: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              client_id: { type: :string },
              project_versions_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    retention_guarantee_rate: { type: :integer },
                    item_groups_attributes: {
                      type: :array,
                      items: {
                        type: :object,
                        properties: {
                          name: { type: :string },
                          description: { type: :string },
                          position: { type: :integer },
                          items_attributes: {
                            type: :array,
                            items: {
                              type: :object,
                              properties: {
                                name: { type: :string },
                                description: { type: :string },
                                position: { type: :integer },
                                quantity: { type: :integer },
                                unit_price_cents: { type: :integer },
                                unit: { type: :string }
                              },
                              required: %w[name position quantity unit_price_cents unit] # Fields required for each item
                            }
                          }
                        },
                        required: %w[name position items_attributes] # Fields required for each item group
                      }
                    }
                  },
                  required: %w[retention_guarantee_rate item_groups_attributes] # Fields required for project version attributes
                }
              }
            },
            required: %w[name project_versions_attributes] # Fields required for the project
          },
          create_project_with_items: {
            type: :object,
            properties: {
              name: { type: :string },
              client_id: { type: :string },
              description: { type: :string },
              project_versions_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    retention_guarantee_rate: { type: :integer },
                    items_attributes: {
                      type: :array,
                      items: {
                        type: :object,
                        properties: {
                          name: { type: :string },
                          description: { type: :string },
                          position: { type: :integer },
                          quantity: { type: :integer },
                          unit_price_cents: { type: :integer },
                          unit: { type: :string }
                        },
                        required: %w[name position quantity unit_price_cents unit] # Fields required for each item
                      }
                    }
                  },
                  required: %w[retention_guarantee_rate items_attributes] # Fields required for project version attributes
                }
              }
            },
            required: %w[name project_versions_attributes] # Fields required for the project
          },
          error: {
            type: :object,
            additionalProperties: false,
            properties: {
              error: {
                type: :object,
                additionalProperties: false,
                properties: {
                  status: { type: :string },
                  code: { type: :integer },
                  message: { type: :string },
                  details: { type: :object, nullable: true }
                },
                required: [ 'status', 'code', 'message', 'details' ]
              }
            },
            required: [ 'error' ]
          },
          **OpenApiDto.registered_dto_schemas
        },
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer
          }
        }
      },
      servers: [
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'www.example.com'
            }
          }
        }
      ]
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
