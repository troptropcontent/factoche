class Organization::Dashboards::MonthlyRevenue < ApplicationRecord
  self.table_name = "monthly_revenues"

  belongs_to :company, class_name: "Organization::Company"

  def readonly?
    true
  end
end
