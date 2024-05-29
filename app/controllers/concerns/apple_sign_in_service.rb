module AppleSignInService
  extend ActiveSupport::Concern
  require 'jwt'
  require 'net/http'
  require 'uri'

  included do
    def decode_and_verify_apple_id_token(token, user_identifier)
      header_segment = JSON.parse(Base64.decode64(token.split(".").first))
      alg = header_segment["alg"]
      kid = header_segment["kid"]
      apple_public_key = fetch_apple_public_key(kid, alg)
      return nil unless apple_public_key

      token_data = JWT.decode(token, apple_public_key, true, {algorithm: alg})[0]

      if token_data.has_key?("sub") && token_data.has_key?("email") && user_identifier == token_data["sub"]
        return token_data
      else
        Rails.logger.error("Apple ID Token validation failed. User Identifier does not match.")
        return nil
      end
    rescue JWT::DecodeError => e
      Rails.logger.error("Apple Sign In Decode Error: #{e.message}")
      nil
    end

    def fetch_apple_public_key(kid, alg)
      apple_response = Net::HTTP.get(URI.parse(Rails.application.credentials.apple[:public_keys_url]))
      apple_certificate = JSON.parse(apple_response)
      keys = JSON.parse(apple_response)['keys']
      apple_key = keys.find { |key| key['kid'] == kid }
      return nil unless apple_key

      keyHash = ActiveSupport::HashWithIndifferentAccess.new(apple_key)
      jwk = JWT::JWK.import(keyHash)

      return jwk.public_key
    end
  end
end