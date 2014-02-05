class AddDateTypeToGoldencobraSettings < ActiveRecord::Migration
  def change
    add_column :goldencobra_settings, :date_type, :date
  end
end
