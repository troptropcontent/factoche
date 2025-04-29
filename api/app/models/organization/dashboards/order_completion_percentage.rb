class Organization::Dashboards::OrderCompletionPercentage < ApplicationRecord
  self.table_name = "order_completion_percentages"

  belongs_to :order, class_name: "Organization::Order"

  def readonly?
    true
  end
end
