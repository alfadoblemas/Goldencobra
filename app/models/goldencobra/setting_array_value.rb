module Goldencobra
  class SettingArrayValue < ActiveRecord::Base
    attr_accessible :setting_id, :value
    belongs_to :setting, :class_name => Goldencobra::Setting
  end
end
