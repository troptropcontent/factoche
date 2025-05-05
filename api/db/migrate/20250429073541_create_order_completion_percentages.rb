class CreateOrderCompletionPercentages < ActiveRecord::Migration[8.0]
  def change
    create_view :order_completion_percentages
  end
end
