class AddIntegerTypeToGoldencobraSettings < ActiveRecord::Migration
  def change
    add_column :goldencobra_settings, :integer_type, :integer
  end
end
