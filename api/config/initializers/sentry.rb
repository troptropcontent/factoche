Sentry.init do |config|
  config.dsn = "https://fc46ff12d12347918fd404edfb6365cd@o4509519980331008.ingest.de.sentry.io/4509519981576272"
  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]

  # Add data like request headers and IP for users,
  # see https://docs.sentry.io/platforms/ruby/data-management/data-collected/ for more info
  config.send_default_pii = true
end
