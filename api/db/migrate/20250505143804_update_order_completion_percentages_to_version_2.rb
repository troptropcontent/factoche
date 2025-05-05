class UpdateOrderCompletionPercentagesToVersion2 < ActiveRecord::Migration[8.0]
  def change
    update_view :order_completion_percentages, version: 2, revert_to_version: 1
  end
end
