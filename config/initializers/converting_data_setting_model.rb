Rails.application.config.to_prepare do
  if ActiveRecord::Base.connection.table_exists?("goldencobra_settings")
    Goldencobra::Setting.update_data_types
  end
end