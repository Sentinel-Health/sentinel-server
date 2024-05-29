if ENV["SENTRY_DSN"]

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.traces_sampler = lambda do |sampling_context|
    # transaction_context is the transaction object in hash form
    # keep in mind that sampling happens right after the transaction is initialized
    # for example, at the beginning of the request
    transaction_context = sampling_context[:transaction_context]

    # transaction_context helps you sample transactions with more sophistication
    # for example, you can provide different sample rates based on the operation or name
    op = transaction_context[:op]
    transaction_name = transaction_context[:name]

    case op
    when /http/
      case transaction_name
      when /\/up/
        0.0 # ignore health_check requests at /up
      else
        0.1
      end
    else
      0.0 # ignore all other transactions
    end
  end

  if Rails.env == "production"
    config.traces_sample_rate = 0.1
    config.profiles_sample_rate = 0.1
  else
    config.traces_sample_rate = 0.0
    config.profiles_sample_rate = 0.0
  end
end

end
