# frozen_string_literal: true

# Explicitly require dry_validation_openapi
# This ensures the gem is loaded before contracts are eager-loaded in production
module DryValidationOpenapi
  module Convertable
  end
end
