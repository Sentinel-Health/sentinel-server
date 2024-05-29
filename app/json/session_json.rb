class SessionJson
  def initialize(session, format = :short)
    @session = session
    @format = (format || :short).to_s.to_sym
  end

  def call(options=nil)
    return to_json(@session, options) unless @session.respond_to?(:each)
    @session.map { |session| to_json(session, options) }
  end

  private

  def to_json(session, options)
    return nil unless session
    Rails.cache.fetch("json/v1.2/#{session.cache_key_with_version}/#{@format.to_s}") do
      case @format
      when :full
        full_json(session, options)
      else
        short_json(session, options)
      end
    end
  end

  def short_json(session, options)
    return nil if session.nil?
    {
      accessToken: session.access_token,
      exp: session.exp,
      iat: session.iat,
      user: UserJson.new(session.user).call
    }
  end

  def full_json(session, options)
    return nil if session.nil?
    {
      **short_json(session, options),
      refreshToken: session.refresh_token,
    }
  end
end