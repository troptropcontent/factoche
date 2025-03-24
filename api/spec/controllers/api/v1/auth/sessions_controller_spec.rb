require "rails_helper"
require "swagger_helper"

RSpec.describe 'Auth API', type: :request do
  path '/api/v1/auth/login' do
    post 'Creates a session' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :session, in: :body, schema: {
        type: :object,
        properties: {
          session: {
            type: :object,
            properties: {
              email: { type: :string, example: 'user@example.com' },
              password: { type: :string, example: 'password123' }
            },
            required: [ 'email', 'password' ]
          }
        }
      }

      response '200', 'session created' do
        schema type: :object,
          properties: {
            access_token: { type: :string },
            refresh_token: { type: :string }
          },
          required: [ 'access_token', 'refresh_token' ]

        let(:user) { FactoryBot.create(:user, email: 'test@example.com', password: 'password123') }
        let(:session) { { session: { email: user.email, password: 'password123' } } }

        run_test!
      end

      response '401', 'invalid credentials' do
        schema ApiError.schema

        let(:session) { { session: { email: 'wrong@example.com', password: 'wrong' } } }

        run_test!
      end
    end
  end

  path '/api/v1/auth/refresh' do
    post 'Refresh the access token' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]

      response '200', 'access token refreshed' do
        schema type: :object,
          properties: {
            access_token: { type: :string }
          },
          required: [ 'access_token' ]

        let(:user) { FactoryBot.create(:user, email: 'test@example.com', password: 'password123') }
        let(:refresh_token) { JwtAuth.generate_refresh_token(user.id) }
        let(:Authorization) { "Bearer #{refresh_token}" }

        run_test!
      end

      response '401', 'invalid token' do
        schema ApiError.schema

        let(:Authorization) { "Bearer invalid" }
        run_test!
      end

      response '401', 'expired token' do
        schema ApiError.schema

        let(:user) { FactoryBot.create(:user, email: 'test@example.com', password: 'password123') }
        let(:token) { travel_to (JwtAuth::REFRESH_TOKEN_EXPIRATION_TIME.before) { JwtAuth.generate_refresh_token(user.id) } }
        let(:Authorization) { "Bearer #{token}" }

        run_test!
      end
    end
  end
end
