class SetDefaultTaxRate < ActiveRecord::Migration[8.0]
  def change
    reversible do |dir|
      dir.up do
        Organization::Item.in_batches do |relation|
          relation.update_all(tax_rate: 0.20)
        end
      end
    end
  end
end
