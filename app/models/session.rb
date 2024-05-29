class Session < ApplicationRecord
  belongs_to :user

  include Jwt

  encrypts :refresh_token, deterministic: true

  def self.create_access_token(user_id)
    payload = {
      uid: user_id,
      exp: 1.hour.from_now.to_i,
      iat: Time.now.to_i,
      aud: "sentinel#{Rails.env == 'production' ? '' : '_' + Rails.env}",
      iss: ENV['JWT_ISSUER']
    }
    return encode(payload), payload
  end

  def self.create_refresh_token(user_id)
    payload = {
      uid: user_id,
      exp: 30.days.from_now.to_i,
      iat: Time.now.to_i,
      aud: "sentinel#{Rails.env == 'production' ? '' : '_' + Rails.env}",
      iss: ENV['JWT_ISSUER']
    }
    return encode(payload)
  end

  def self.decode_token(token)
    opts = { 
        required_claims: ['exp', 'iat', 'aud', 'iss'],
        iss: ENV['JWT_ISSUER'],
        verify_iss: true,
        aud: "sentinel#{Rails.env == 'production' ? '' : '_' + Rails.env}",
        verify_aud: true,
        verify_iat: true,
      }
    decode(token, opts)
  end

  def self.find_and_verify(access_token)
    decoded_token = decode_token(access_token)
    session = Session.find_by(access_token: access_token)
    return nil if session.nil? || decoded_token.nil?
    user_id = decoded_token.dig('uid')
    return nil if user_id != session.user.id
    return session
  end

  def self.find_and_verify_refresh_token(refresh_token)
    decoded_token = decode_token(refresh_token)
    session = Session.find_by(refresh_token: refresh_token)
    return nil if session.nil? || decoded_token.nil?
    user_id = decoded_token.dig('uid')
    return nil if user_id != session.user.id
    return session
  end

  def refresh_access_token!
    new_token, new_payload = Session.create_access_token(self.user.id)
    new_refresh_token = Session.create_refresh_token(self.user.id)
    self.update!(
      access_token: new_token,
      refresh_token: new_refresh_token,
      exp: new_payload[:exp],
      iat: new_payload[:iat]
    )
    return new_token, new_refresh_token
  end
end
