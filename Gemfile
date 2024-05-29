source "https://rubygems.org"

ruby "3.3.0"

gem "rails", "~> 7.1.3"

# Drivers
gem "pg", "~> 1.1"
gem "redis", ">= 4.0.1"

# Deployment
gem "puma", ">= 5.0"
gem "bootsnap", require: false

# Assets
gem "sprockets-rails"
gem "importmap-rails"

# Hotwire
gem "turbo-rails"
gem "stimulus-rails"

# Background Jobs
gem "sidekiq", "~> 7.2", ">= 7.2.4"

# Queries
gem "groupdate", "~> 6.4"

# Auditing
gem 'console1984'
# gem 'audits1984'
gem 'browser'

# Security
gem 'rack-attack'
gem 'rack-cors'

# Other
gem "jbuilder"
gem "jwt", "~> 2.7"
gem "oj", "~> 3.16"
gem "faraday"
gem "stripe"
gem "phonelib"
gem "twilio-ruby"
gem "ruby-openai", ">= 5.2"
gem "sentry-ruby", "~> 5.12"
gem "sentry-rails", "~> 5.12"
gem "stackprof"
gem "aws-sdk-sns", "~> 1.68"
gem "retriable", "~> 3.1"
gem "pinecone"
gem "kaminari", "~> 1.2"
gem "aws-sdk-s3", "~> 1.138"
gem "aws-sdk-ses"
gem "tzinfo-data", platforms: %i[ windows jruby ]
# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"
gem "image_processing", "~> 1.2"
gem "mime-types"
gem 'acts-as-taggable-on'

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
  gem 'dotenv-rails'
  gem "brakeman", require: false
  gem "letter_opener"
  gem "i18n-tasks"
end

group :development do
  gem "web-console"
  gem "hotwire-livereload"
  gem "ruby-lsp-rails"
  gem "dockerfile-rails", ">= 1.5"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver", ">= 4.16.0"
end
