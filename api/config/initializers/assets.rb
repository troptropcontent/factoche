Rails.application.configure do
  config.assets.paths << Rails.root.join("app/assets")
  config.assets.prefix = "/assets"
end
