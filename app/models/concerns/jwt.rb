module Jwt
  require 'jwt'
  extend ActiveSupport::Concern

  class_methods do
    def encode(payload)
      JWT.encode(payload, Rails.application.credentials.jwt_secret, 'HS256')
    end

    def decode(token, options = {})
      options[:algorithm] = 'HS256'
      JWT.decode(token, Rails.application.credentials.jwt_secret, true, options)[0]
    end
  end
end