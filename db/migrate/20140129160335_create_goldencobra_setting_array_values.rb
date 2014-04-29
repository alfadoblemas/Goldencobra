class CreateGoldencobraSettingArrayValues < ActiveRecord::Migration
  def change
    create_table :goldencobra_setting_array_values do |t|
      t.integer :setting_id
      t.string :value

      t.timestamps
    end
  end
end
