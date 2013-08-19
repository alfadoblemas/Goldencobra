# encoding: utf-8

# == Schema Information
#
# Table name: goldencobra_imports
#
#  id                :integer          not null, primary key
#  assignment        :text
#  assignment_groups :text
#  target_model      :string(255)
#  successful        :boolean
#  upload_id         :integer
#  separator         :string(255)      default(",")
#  result            :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#


# Dynamische Importfunktionen:
# Jedes Model welches eigene Importfunktionen anbieten will muss lediglich eine liste der verfügbaren funktionen ImportDataFunctions = [] haben
# und die entsprechenden parameterized.underscored klassenfunktionenen bereithalten

module Goldencobra
  class Import < ActiveRecord::Base
    require 'iconv'
    require 'csv'

    belongs_to :upload, :class_name => Goldencobra::Upload
    serialize :assignment
    serialize :assignment_groups
    EncodingTypes = ["UTF-8","ISO-8859-1", "ISO-8859-2", "ISO-8859-16", "US-ASCII", "Big5", "UTF-16BE", "IBM437", "Windows-1252"]
    accepts_nested_attributes_for :upload, :allow_destroy => true, :reject_if => proc { |attributes| attributes['image'].blank? }
    after_initialize :init_nested_attributes
    BlockedAttributes = ["id", "created_at", "updated_at", "url_name", "slug", "upload_id", "images", "article_images", "article_widgets", "permissions", "versions"]
    DataHandling = [["bestehenden Datensatz suchen oder erstellen","update"],["Datensatz immer neu anlegen", "create"]]
    DataFunctions = ["Default", "Static Value", "DateTime"]
    def analyze_csv
      begin
        result = []
        data = CSV.read(self.upload.image.path, "r:#{self.encoding_type}", {:col_sep => self.separator})
        data.first.each_with_index do |a, index|
          result << [a,index.to_s]
        end
      rescue
        result = []
      end
      @analyze_csv ||= result
    end

    def data_rows
      begin
        CSV.read(self.upload.image.path, "r:#{self.encoding_type}", {:col_sep => self.separator})
      rescue
        [["Error in reading File: Please check encoding type"]]
      end
    end

    def get_model_attributes
      @get_model_attributes ||= eval("#{self.target_model}.new.attributes").delete_if{|a| BlockedAttributes.include?(a) }.keys
    end

    def get_association_names(current_target_model=nil)
      if current_target_model.present?
        current_target_model.reflect_on_all_associations.collect { |r| r.name }.delete_if{|a| Goldencobra::Import::BlockedAttributes.include?(a.to_s) }
      else
        self.target_model.constantize.reflect_on_all_associations.collect { |r| r.name }.delete_if{|a| Goldencobra::Import::BlockedAttributes.include?(a.to_s) }
      end
    end

    def method_missing(meth, *args, &block)
      if meth.to_s.include?("assignment_") && self.assignment.present?
        self.assignment[meth.to_s.split("_")[1]]
      end
    end

    def status
      @status ||="ready to import"
    end

    def run!
      self.result = []
      count = 0
      all_data_attribute_assignments = remove_emty_assignments
      master_data_attribute_assignments = all_data_attribute_assignments[self.target_model]
      import_data_attribute_assignments = all_data_attribute_assignments["Goldencobra::ImportMetadata"]
      #all_data_attribute_assignments.delete("Goldencobra::ImportMetadata")

      data = CSV.read(self.upload.image.path, "r:#{self.encoding_type}", {:col_sep => self.separator})
      data.each do |row|
        if count == 0
          count = 1
          next
        end
        master_object = nil
        current_object = nil
        #Neues Object anlegen oder bestehendes suchen und aktualisieren
        if self.assignment_groups[self.target_model] == "create"
          master_object = self.target_model.constantize.new
        else
          master_object = find_or_create_by_attributes(master_data_attribute_assignments, row, self.target_model)
        end

        #Gehe alle Zugewiesenen Attribute durch und erzeuge die Datensätze
        all_data_attribute_assignments.each do |key,sub_assignments|
          logger.warn("#"*40 + " - LINE 106 - all_data_attribute_assignments")
          next if key == "Goldencobra::ImportMetadata"
          if key == self.target_model
            current_object = master_object
          else
            #Wenn das Aktuelle object nicht das MasterObject ist sondern ein Unterelement
            # Suche unter allen möglciehn Unterobjecten das passende aus und speichere es in current_object zwischen
            master_object.class.reflect_on_all_associations.collect { |r| r.name }.each do |cass|
              if master_object.send(cass).class == Array
                #Bei einer has_many beziehung
                cass_related_model = eval("master_object.#{cass}.new")
              else
                #bei einer belongs_to Beziehung
                cass_related_model = master_object.send("build_#{cass}")
              end
              if cass_related_model.class == key.constantize
                begin
                  cass_related_model.destroy
                rescue
                  #nix machen
                end
                #Neues Unter Object anlegen oder bestehendes suchen und aktualisieren
                if self.assignment_groups[key] == "create"
                  current_object = key.constantize.new
                else
                  current_object = find_or_create_by_attributes(sub_assignments, row, key)
                end
                #Das aktuelle unterobjeect wird dem Elternelement hinzugefügt
                # wenn es eine has_many beziehung ist:
                begin
                  if master_object.send(cass).class == Array
                    master_object.send(cass) << current_object
                  else
                    eval("master_object.#{cass} = current_object")
                  end
                rescue
                  #self.result << "E:#{count}"
                end
                break
              end
            end
          end
          #die Werte für das Object werden gesetzt
          sub_assignments.each do |attribute_name,value|
            #Wenn das Aktuell zu speichernde Attribute kein attribute sondern eine Assoziazion zu einem anderen Model ist...
            sub_assoziations = current_object.class.reflect_on_all_associations.collect { |r| [r.name, r.macro] }.map{|a| a[1].to_s == "has_many" ? [current_object.send(a[0]).new.class.to_s, a[0]] : [current_object.respond_to?("build_#{a[0]}") ? current_object.send("build_#{a[0]}").class.to_s : "", a[0]]}
            if sub_assoziations.map{|a| a[0]}.include?(attribute_name)
              logger.warn("#"*40 + " - LINE 152 - sub_assoziations")
              self.assignment["#{current_object.class.to_s}"][attribute_name].each do |sub_attribute_name, sub_value|
                if current_object.send(sub_attribute_name).class == Array
                  #Bei einer has_many beziehung
                  cass_related_sub_model = eval("current_object.#{sub_attribute_name}.new")
                else
                  #bei einer belongs_to Beziehung
                  cass_related_sub_model = current_object.send("build_#{sub_attribute_name}")
                end
                begin
                  cass_related_sub_model.destroy
                rescue
                  #nix machen
                end
                sub_sub_assignments = self.assignment["#{current_object.class.to_s}"][attribute_name][sub_attribute_name]
                #Neues Unter Object anlegen oder bestehendes suchen und aktualisieren
                if self.assignment_groups["#{current_object.class.to_s}_#{cass_related_sub_model.class.to_s}_#{sub_attribute_name}"] == "create"
                  current_sub_object = attribute_name.constantize.new
                  logger.warn("#"*40 + " - LINE 170 - new")
                else
                  logger.warn("#"*40 + " - LINE 171 - update")
                  current_sub_object = find_or_create_by_attributes(sub_sub_assignments, row, attribute_name)
                end
                #Das aktuelle unterobjeect wird dem Elternelement hinzugefügt
                # wenn es eine has_many beziehung ist:
                begin
                  if current_object.send(sub_attribute_name).class == Array
                    current_object.send(sub_attribute_name) << current_sub_object
                  else
                    eval("current_object.#{sub_attribute_name} = current_sub_object")
                  end
                rescue
                  #self.result << "E:#{count}"
                end
                sub_sub_assignments.each do |sub_ass_item|
                  sub_data_to_save = parse_data_with_method(row[value['csv'].to_i],value['data_function'],value['option'], current_sub_object.class.to_s)
                  next if sub_data_to_save.blank?
                  current_sub_object.send("#{sub_ass_item}=", sub_data_to_save)
                end
                current_sub_object.save
              end
            else
              data_to_save = parse_data_with_method(row[value['csv'].to_i],value['data_function'],value['option'], current_object.class.to_s)
              next if data_to_save.blank?
              #Wenn das Aktuell zu speichernde Attribute wirklich ein Attribute ist, kann es gespeichert werden
              current_object.send("#{attribute_name}=", data_to_save)
            end
          end
          #Das Object wird gespeichert
          if current_object.save
            #Create ImportMetadata
            import_metadata = Goldencobra::ImportMetadata.new
            import_data_attribute_assignments.each do |attribute_name,value|
              data_to_save = parse_data_with_method(row[value['csv'].to_i],value['data_function'],value['option'], "Goldencobra::ImportMetadata")
              next if data_to_save.blank?
              import_metadata.send("#{attribute_name}=", data_to_save)
            end
            import_metadata.importmetatagable = current_object
            import_metadata.save
          else
            #self.result << "#{count} - SubObject: #{current_object.errors.messages}"
          end
        end
        #Das Elternelement wird gespeichert
        unless master_object.save
          #self.result << "#{count} - #{master_object.errors.messages}"
        end
        count += 1
      end
      self.save
    end

    def init_nested_attributes
      self.upload ||= build_upload
      self.assignment ||= {}
    end

    def find_or_create_by_attributes(attribute_assignments, row, model_name)
      find_condition = []
      attribute_assignments.each do |attribute_name,value|
        data_to_search = parse_data_with_method(row[value['csv'].to_i],value['data_function'],value['option'], model_name)
        next if data_to_search.blank?
        find_condition << "#{attribute_name} = '#{data_to_search}'"
      end
      find_master = model_name.constantize.where(find_condition.join(' AND '))

      if find_master.count == 0
        return model_name.constantize.new
      elsif find_master.count == 1
        return find_master.first
      else
        self.result << "Dieses Object exisitiert schon mehrfach, keine eindeutige Zuweisung möglich: Erstes Objekt wird verwendet (#{row})"
        return find_master.first
      end
    end

    #SELECT COUNT(*) FROM `providers` WHERE (title = 'Sportgemeinschaft Siemens Berlin e. V.' AND category_id = '3' AND metatag_external_id = '1804' AND metatag_created_at = '06.01.2010')

    def parse_data_with_method(data,data_function,data_option, model_name="")
      conv = Iconv.new("UTF-8", self.encoding_type)
      output = conv.iconv(data)
      if data_function == "Default"
        return output
      elsif data_function == "Static Value"
        return data_option
      elsif data_function == "DateTime"
        if output.present? && data_option.present?
          return DateTime.strptime(output,data_option).strftime("%Y-%m-%d %H:%M")
        else
          return output
        end
      elsif model_name.present?
        if data_function.present? && model_name.constantize.respond_to?(data_function.parameterize.underscore)
          return model_name.constantize.send(data_function.parameterize.underscore, data, data_option )
        else
          return ""
        end
      else
        return ""
      end
    end

    def remove_emty_assignments
      self.assignment.each do |key, values|
        self.assignment[key].delete_if{|key,value| value['data_function'] == "Default" && value['csv'].blank?}
        if self.assignment[key].blank?
          self.assignment.delete(key)
        end
      end
      self.assignment
    end

  end
end
