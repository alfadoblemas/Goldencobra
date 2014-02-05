class AddBooleanTypeToGoldencobraSettings < ActiveRecord::Migration
  def change
    add_column :goldencobra_settings, :boolean_type, :boolean
  end
end
