# spec/lib/jwt_auth_spec.rb
require 'rails_helper'

RSpec.describe JwtAuth do
  let(:user_id) { 123 }

  describe '.generate_access_token' do
    let(:access_token) { described_class.generate_access_token(user_id) }
    let(:decoded_token) do
      JWT.decode(
        access_token,
        Rails.application.credentials.token_secrets.access,
      ).first
    end

    it 'generates a valid JWT token' do
      expect { decoded_token }.not_to raise_error
    end

    it 'includes the correct user_id in the subject claim' do
      expect(decoded_token['sub']).to eq(user_id.to_s)
    end

    it 'sets the correct expiration time' do
      expected_exp = Time.now.to_i + described_class::ACCESS_TOKEN_EXPIRATION_TIME
      expect(decoded_token['exp']).to be_within(5).of(expected_exp)
    end

    it 'includes issued at time' do
      expect(decoded_token['iat']).to be_within(5).of(Time.now.to_i)
    end

    it 'includes a JWT ID' do
      expect(decoded_token['jti']).to be_present
      expect(decoded_token['jti']).to match(/^[0-9a-f-]{36}$/) # UUID format
    end
  end

  describe '.generate_refresh_token' do
    let(:refresh_token) { described_class.generate_refresh_token(user_id) }
    let(:decoded_token) do
      JWT.decode(
        refresh_token,
        Rails.application.credentials.token_secrets.refresh,
        true
      ).first
    end

    it 'generates a valid JWT token' do
      expect { decoded_token }.not_to raise_error
    end

    it 'includes the correct user_id in the subject claim' do
      expect(decoded_token['sub']).to eq(user_id.to_s)
    end

    it 'sets the correct expiration time' do
      expected_exp = Time.now.to_i + described_class::REFRESH_TOKEN_EXPIRATION_TIME
      expect(decoded_token['exp']).to be_within(5).of(expected_exp)
    end

    it 'includes issued at time' do
      expect(decoded_token['iat']).to be_within(5).of(Time.now.to_i)
    end

    it 'includes a JWT ID' do
      expect(decoded_token['jti']).to be_present
      expect(decoded_token['jti']).to match(/^[0-9a-f-]{36}$/) # UUID format
    end
  end

  describe 'token differences' do
    it 'generates different tokens for the same user_id' do
      token1 = described_class.generate_access_token(user_id)
      token2 = described_class.generate_access_token(user_id)
      expect(token1).not_to eq(token2)
    end

    it 'uses different secrets for access and refresh tokens' do
      access_token = described_class.generate_access_token(user_id)
      refresh_token = described_class.generate_refresh_token(user_id)

      # Verify that tokens can't be decoded with wrong secrets
      expect {
        JWT.decode(access_token, Rails.application.credentials.token_secrets.refresh)
      }.to raise_error(JWT::VerificationError)

      expect {
        JWT.decode(refresh_token, Rails.application.credentials.token_secrets.access)
      }.to raise_error(JWT::VerificationError)
    end
  end
end
