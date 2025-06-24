# spec/lib/jwt_auth_spec.rb
require 'rails_helper'

RSpec.describe JwtAuth do
  let(:user_id) { 123 }

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe '.generate_token' do
    let(:secret) { "abcde" }
    let(:expiration) { 1.hours }
    let(:resource_id) { 0 }
    let(:token) { described_class.generate_token(resource_id, secret, expiration) }

    let(:payload) do
      JWT.decode(
        token,
        secret,
      ).first
    end

    it 'generates a valid JWT token' do
      expect { payload }.not_to raise_error
    end

    it 'includes the correct resource_id in the subject claim' do
      expect(payload['sub']).to eq(resource_id.to_s)
    end

    it 'sets the correct expiration time' do
      expected_exp = Time.now.to_i + expiration
      expect(payload['exp']).to be_within(5).of(expected_exp)
    end

    it 'includes issued at time' do
      expect(payload['iat']).to be_within(5).of(Time.now.to_i)
    end

    it 'includes a JWT ID', :aggregate_failures do
      expect(payload['jti']).to be_present
      expect(payload['jti']).to match(/^[0-9a-f-]{36}$/) # UUID format
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers

  describe '.generate_access_token' do
    let(:access_token) { described_class.generate_access_token(user_id) }
    let(:decoded_token) do
      JWT.decode(
        access_token,
        ENV.fetch("ACCESS_TOKEN_SECRET"),
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

    it 'includes a JWT ID', :aggregate_failures do
      expect(decoded_token['jti']).to be_present
      expect(decoded_token['jti']).to match(/^[0-9a-f-]{36}$/) # UUID format
    end
  end

  describe '.generate_refresh_token' do
    let(:refresh_token) { described_class.generate_refresh_token(user_id) }
    let(:decoded_token) do
      JWT.decode(
        refresh_token,
        ENV.fetch("REFRESH_TOKEN_SECRET"),
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

    it 'includes a JWT ID', :aggregate_failures do
      expect(decoded_token['jti']).to be_present
      expect(decoded_token['jti']).to match(/^[0-9a-f-]{36}$/) # UUID format
    end
  end

  describe '.decode_token' do
    let(:secret) { "abcde" }
    let(:expiration) { 1.hours }
    let(:resource_id) { 0 }
    let(:token) { described_class.generate_token(resource_id, secret, expiration) }

    it 'successfully decodes a valid access token' do
      decoded_payload = described_class.decode_token(token, secret)

      expect(decoded_payload["sub"]).to eq(resource_id.to_s)
    end

    it 'raises JWT::DecodeError when token is invalid' do
      expect {
        described_class.decode_token("invalid_token", secret)
      }.to raise_error(JWT::DecodeError)
    end

    it 'raises JWT::DecodeError when token is expired' do
      token
      travel_to(1.days.from_now) do
        expect {
          described_class.decode_token(token, secret)
        }.to raise_error(JWT::ExpiredSignature)
      end
    end
  end

  describe '.decode_access_token' do
    let(:user_id) { 123 }

    it 'successfully decodes a valid access token' do
      token = described_class.generate_access_token(user_id)
      decoded_payload = described_class.decode_access_token(token)

      expect(decoded_payload["sub"]).to eq(user_id.to_s)
    end

    it 'raises JWT::DecodeError when token is invalid' do
      expect {
        described_class.decode_access_token("invalid_token")
      }.to raise_error(JWT::DecodeError)
    end

    it 'raises JWT::DecodeError when token is expired' do
      token = described_class.generate_access_token(user_id)
      travel_to(described_class::ACCESS_TOKEN_EXPIRATION_TIME.from_now) do
        expect {
          described_class.decode_access_token(token)
        }.to raise_error(JWT::ExpiredSignature)
      end
    end
  end

  describe '.decode_refresh_token' do
    let(:user_id) { 123 }

    it 'successfully decodes a valid access token' do
      token = described_class.generate_refresh_token(user_id)
      decoded_payload = described_class.decode_refresh_token(token)
      expect(decoded_payload["sub"]).to eq(user_id.to_s)
    end

    it 'raises JWT::DecodeError when token is invalid' do
      expect {
        described_class.decode_refresh_token("invalid_token")
      }.to raise_error(JWT::DecodeError)
    end

    it 'raises JWT::DecodeError when token is expired' do
      token = described_class.generate_refresh_token(user_id)
      travel_to(described_class::REFRESH_TOKEN_EXPIRATION_TIME.from_now + 1.days) do
        expect {
          described_class.decode_refresh_token(token)
        }.to raise_error(JWT::ExpiredSignature)
      end
    end
  end

  describe 'token differences' do
    it 'generates different tokens for the same user_id' do
      token1 = described_class.generate_access_token(user_id)
      token2 = described_class.generate_access_token(user_id)
      expect(token1).not_to eq(token2)
    end

    it 'uses different secrets for access and refresh tokens', :aggregate_failures do
      access_token = described_class.generate_access_token(user_id)
      refresh_token = described_class.generate_refresh_token(user_id)

      # Verify that tokens can't be decoded with wrong secrets
      expect {
        JWT.decode(access_token,  ENV.fetch("REFRESH_TOKEN_SECRET"))
      }.to raise_error(JWT::VerificationError)

      expect {
        JWT.decode(refresh_token,  ENV.fetch("ACCESS_TOKEN_SECRET"))
      }.to raise_error(JWT::VerificationError)
    end
  end

  describe '.find_token' do
    let(:headers) { {} }
    let(:request) { Struct.new(:headers).new(headers) }

    context 'when Authorization header is present with valid Bearer token' do
      let(:headers) { { 'Authorization' => 'Bearer valid_token_123' } }

      it 'returns the token' do
        expect(described_class.find_token(request)).to eq('valid_token_123')
      end
    end

    context 'when Authorization header is present but not in Bearer format' do
      let(:headers) { { 'Authorization' => 'Basic some_token' } }

      it 'returns nil' do
        expect(described_class.find_token(request)).to be_nil
      end
    end

    context 'when Authorization header is missing' do
      let(:headers) { {} }

      it 'returns nil' do
        expect(described_class.find_token(request)).to be_nil
      end
    end

    context 'when Authorization header is nil' do
      let(:headers) { { 'Authorization' => nil } }

      it 'returns nil' do
        expect(described_class.find_token(request)).to be_nil
      end
    end
  end
end
