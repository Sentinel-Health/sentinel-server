Rails.application.config.middleware.insert_before 0, Rack::Cors do
  # Development environment
  if Rails.env.development?
    allow do
      origins 'https://localinternalapi.sentinelhealth.dev', 'https://localapp.sentinelhealth.dev', 'http://localhost:3000', 'http://localhost:5000', 'localhost:8080'
      resource '/*',
        headers: :any,
        methods: [:get, :post, :put, :delete, :options, :head]
    end
  end

  # Staging environment
  if Rails.env.staging?
    allow do
      origins 'https://internal-api.sentinelhealth.dev', 'https://app.sentinelhealth.dev', 'https://admin.sentinelhealth.dev'
      resource '/*',
        headers: :any,
        methods: [:get, :post, :put, :delete, :options, :head]
    end
  end

  # Production environment
  if Rails.env.production?
    allow do
      origins 'https://internal-api.sentinelhealth.co', 'https://app.sentinelhealth.co', 'https://admin.sentinelhealth.co'
      resource '/*',
        headers: :any,
        methods: [:get, :post, :put, :delete, :options, :head]
    end
  end
end