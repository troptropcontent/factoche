class CreateMonthlyRevenues < ActiveRecord::Migration[8.0]
  def change
    create_view :monthly_revenues
  end
end
