module OpenAiError
  class Error < StandardError; end

  class Unauthorized < Error
    def initialize(msg="Unauthorized")
      super(msg)
    end
  end

  class RateLimit < Error
    def initialize(msg="Rate limit exceeded")
      super(msg)
    end
  end

  class BadRequest < Error
    def initialize(msg="Bad request")
      super(msg)
    end
  end

  class ServerError < Error
    def initialize(msg="Server error")
      super(msg)
    end
  end

  class ServerOverloaded < Error
    def initialize(msg="Server overloaded")
      super(msg)
    end
  end
end