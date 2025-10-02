module Accounting
  ProjectSchema = Dry::Schema.Params do
    required(:name).filled(:string)
  end
end
