require_relative "../../app/services/headless_browser_pdf_generator"

# Fetch and set the environment variables, raising an error if they are not present
print_microservice_url = ENV.fetch("FABATI_PRINT_MICROSERVICE_URL") do
  raise "Environment variable FABATI_PRINT_MICROSERVICE_URL is missing"
end

headless_browser_ws = ENV.fetch("FABATI_HEADLESS_BROWSER_WS") do
  raise "Environment variable FABATI_HEADLESS_BROWSER_WS is missing"
end

headless_browser_token = ENV.fetch("FABATI_HEADLESS_BROWSER_TOKEN") do
  raise "Environment variable FABATI_HEADLESS_BROWSER_TOKEN is missing"
end
