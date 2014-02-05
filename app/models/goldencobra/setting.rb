# encoding: utf-8

# == Schema Information
#
# Table name: goldencobra_settings
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  value      :string(255)
#  ancestry   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  data_type  :string(255)      default("string")
#

module Goldencobra
  class Setting < ActiveRecord::Base
    @@key_value = {}
    attr_accessible :title, :value, :ancestry, :parent_id, :data_type, :set_value, :date_type, :datetime_type, :integer_type, :array_type, :setting_array_values_attributes
    attr_writer :set_value
    attr_accessor :set_value
    has_many :setting_array_values, :class_name => Goldencobra::SettingArrayValue

    accepts_nested_attributes_for :setting_array_values, :allow_destroy => true

    #composed_of :value, converter: Proc.new { |stringdate| stringdate.strptime("%Y-%d-%m")}

    #serialize :value   # does saving to database in the right data type (but for now save as string)
    #before_save :convert_value2  #figure out how to do that
    before_save :form_value_to_string  #figure out how to do that
    SettingsDataTypes = ["string","date","datetime","boolean","array", "integer"]
    SettingsDataTypesH = {"string" => "string","date" => "date_select","datetime"=> "datetime_select", "integer" => "number", "boolean"=> "boolean","array"=> "string"}
    has_ancestry :orphan_strategy => :restrict
    if ActiveRecord::Base.connection.table_exists?("versions")
      has_paper_trail
    end
    before_save :parse_title
    after_update :update_cache

    scope :parent_ids_in_eq, lambda { |art_id| subtree_of(art_id) }
    search_methods :parent_ids_in_eq

    scope :parent_ids_in, lambda { |art_id| subtree_of(art_id) } if ActiveRecord::Base.connection.table_exists?("goldencobra_settings") && Goldencobra::Setting.all.any?
    search_methods :parent_ids_in

    scope :with_values, where("value IS NOT NULL")

#### ---->

#      logger.warn("---"*20)

    def form_value_to_string  
      if Goldencobra::Setting.new.respond_to?(:date_type) 
        if self.data_type == "boolean" 
          if self.set_value == "0" 
            self.value = "false" 
          elsif self.set_value == "1"
            self.value = "true"
          end
        elsif self.data_type == "date" && self.date_type.present?
          self.value = self.date_type.strftime("%Y-%m-%d")
        elsif self.data_type == "datetime" && self.datetime_type.present?
          self.value = self.datetime_type.strftime("%Y-%m-%d %H:%M")
        elsif self.data_type == "array"
          self.value = self.setting_array_values.map{|a|a.value}.join(",")
        elsif self.data_type == "integer"
          self.value = self.integer_type.to_s
        else
          self.value = self.set_value
        end
      end
    end

    def self.update_data_types
      Goldencobra::Setting.scoped.each do |s|
        s.change_data_types
      end
    end

    def change_data_types

      if self.value == "false" || self.value == "0"
        self.value = "false"
        self.data_type = "boolean"
        self.save
      elsif self.value == "true" || self.value == "1" 
        self.value = "true"
        self.data_type = "boolean"
        self.save
      end

      if self.value.to_i.to_s == self.value && self.value.to_i > 1
        self.integer_type = self.value.to_i          
        self.data_type = "integer"
        self.save
      end

      begin
        Date.parse(self.value).strftime("%Y-%m-%d") != self.value
      rescue
        puts "Oops, not a date."
      else 
        if Date.parse(self.value).strftime("%Y-%m-%d") == self.value
        self.date_type = Date.parse(self.value)
        self.data_type = "date"
        self.save
        end
      end

      begin
        DateTime.parse(self.value).strftime("%Y-%m-%d %H:%M") != self.value
      rescue
        puts "Oops, not a datetime."
      else 
        if DateTime.parse(self.value).strftime("%Y-%m-%d %H:%M") == self.value
        self.datetime_type = DateTime.parse(self.value)
        self.data_type = "datetime"
        self.save
        end
      end
    end

    def data_values
      SettingsDataTypesH[self.data_type]
    end
      
#### ----> 


    def self.absolute_base_url
      if Goldencobra::Setting.for_key("goldencobra.use_ssl") == "true"
        "https://#{Goldencobra::Setting.for_key('goldencobra.url')}"
      else
        "http://#{Goldencobra::Setting.for_key('goldencobra.url')}"
      end
    end

    def self.regenerate_active_admin
      if defined?(ActiveAdmin) and ActiveAdmin.application
        ActiveAdmin.application.unload!
        ActiveSupport::Dependencies.clear
        ActiveAdmin.application.load!
      end
    end


    def self.for_key(name, cacheable=true)
      if cacheable
        @@key_value ||= {}
        @@key_value[name] ||= for_key_helper(name)
      else
        for_key_helper(name)
      end
    end

    def self.for_key_helper(name)
    if ActiveRecord::Base.connection.table_exists?("goldencobra_settings")
      setting_title = name.split(".").last
      settings = Goldencobra::Setting.where(:title => setting_title)
      if settings.count == 1
        return settings.first.value
      elsif settings.count > 1
        settings.each do |set|
          if [set.ancestors.map(&:title).join("."),setting_title].compact.join('.') == name
            return set.value
          end
        end
      else
        return setting_title
      end
    end
    end

    def self.set_value_for_key(value, name, data_type_name="string")
      @@key_value = nil
      if ActiveRecord::Base.connection.table_exists?("goldencobra_settings")
        setting_title = name.split(".").last
        settings = Goldencobra::Setting.where(:title => setting_title)
        if settings.count == 1
          settings.first.update_attributes(value: value, data_type: data_type_name)
          true
        elsif settings.count > 1
          settings.each do |set|
            if [set.ancestors.map(&:title).join("."),setting_title].compact.join('.') == name
              set.update_attributes(value: value, data_type: data_type_name)
              true
            end
          end
        else
          false
        end
      end
    end

    def self.import_default_settings(path_file_name)
      if ActiveRecord::Base.connection.table_exists?("goldencobra_settings")
        require 'yaml'
        raise "Settings File '#{path_file_name}' does not exist" if !File.exists?(path_file_name)
        imports = open(path_file_name) {|f| YAML.load(f) }
        imports.each_key do |key|
          generate_default_setting(key, imports)
        end
      end
    end

    def parent_names
      self.ancestors.map(&:title).join(".")
    end


    private
    def self.generate_default_setting(key, yml_data, parent_id=nil)
      if yml_data[key].class == Hash
        #check if childen keys are value and type or not
        if yml_data[key].keys.count == 2 && yml_data[key].keys.sort == ["type","value"]
          #new way of defining settings by additional value and type params
          create_setting_by_key_and_parent_and_type_and_value(key,parent_id, yml_data[key]["type"], yml_data[key]["value"])
        else
          #old way of defining Settings
          parent = Setting.find_by_ancestry_and_title(parent_id, key)
          unless parent
            parent = Setting.create(:ancestry => parent_id, :title => key)
          end
          yml_data[key].each_key do |name|
            generate_default_setting(name, yml_data[key], [parent.ancestry,parent.id].compact.join('/'))
          end
        end
      elsif yml_data[key].class == String
        create_setting_by_key_and_parent_and_type_and_value(key,parent_id, "string", yml_data[key])
      else
        raise "invalid yml File at: #{key}  -  #{yml_data}"
      end
    end


    def self.create_setting_by_key_and_parent_and_type_and_value(key,parent, data_type_name, value_name)
      set = Goldencobra::Setting.find_by_title_and_ancestry(key, parent)
      unless set
        if Goldencobra::Setting.new.respond_to?(:data_type)
          Goldencobra::Setting.create(:title => key , :value => value_name, :ancestry => parent, :data_type => data_type_name )
        else
          if data_type_name == "string"
            Goldencobra::Setting.create(:title => key , :value => value_name, :ancestry => parent)
          end
        end
      end
    end


    def parse_title
      if self.title.present?
        self.title = self.title.downcase
        self.title = self.title.gsub(".", "_")
      end
    end

    def update_cache
      @@key_value = nil
    end

  end
end
