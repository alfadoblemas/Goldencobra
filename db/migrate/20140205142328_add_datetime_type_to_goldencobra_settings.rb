class AddDatetimeTypeToGoldencobraSettings < ActiveRecord::Migration
  def change
    add_column :goldencobra_settings, :datetime_type, :datetime
  end
end
