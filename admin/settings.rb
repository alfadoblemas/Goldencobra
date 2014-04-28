# encoding: utf-8

ActiveAdmin.register Goldencobra::Setting, :as => "Setting"  do
  menu :parent => I18n.t("settings", :scope => ["active_admin","menue"]), :if => proc{can?(:update, Goldencobra::Setting)}

  controller.authorize_resource :class => Goldencobra::Setting
  scope "Alle Settings", :with_values, :default => true
  if ActiveRecord::Base.connection.table_exists?("goldencobra_settings") && Goldencobra::Setting.all.count > 0
    # Goldencobra::Setting.roots.each do |rs|
    #   scope(rs.title){ |t| t.parent_ids_in(rs.id).with_values }
    # end
  end

  form :html => { :enctype => "multipart/form-data" }  do |f|
    f.inputs I18n.t('active_admin.settings.form.general')  do
      f.input :title, :input_html => {:disabled => "disabled"}
      if f.object.data_type == "date"  
        f.input :date_type, :as => f.object.data_values 
      elsif f.object.data_type == "datetime"
        f.input :datetime_type, :as => f.object.data_values
      elsif f.object.data_type == "string"
      f.input :value, :as => f.object.data_values 
      elsif f.object.data_type == "integer" ##
        f.input :integer_type, :as => f.object.data_values ##
      elsif f.object.data_type == "array"
        f.has_many :setting_array_values do |arr|
          arr.input :value, :as => f.object.data_values
        end
      elsif f.object.data_type == "boolean"
        f.input :set_value, :as => f.object.data_values, :input_html => {:checked => f.object.value == "true" ? true : false}
      else
        f.input :set_value, :as => f.object.data_values
      end
      f.input :data_type, :as => :select, :collection => Goldencobra::Setting::SettingsDataTypes, :include_blank => false
      f.input :parent_id, :as => :select, :collection => Goldencobra::Setting.all.map{|c| [c.title, c.id]}, :include_blank => true
    end
    f.actions
  end

  index do
    selectable_column
    column :id
    column :title do |setting|
      link_to "#{setting.parent_names}.#{setting.title}", edit_admin_setting_path(setting)
    end
    column :value
    column :data_type
    column "" do |setting|
      result = ""
      result += link_to(t(:edit), edit_admin_setting_path(setting), :class => "member_link edit_link edit", :title => "bearbeiten")
      raw(result)
    end
  end


  sidebar :overview, only: [:index]  do
    render :partial => "/goldencobra/admin/shared/overview", :object => Goldencobra::Setting.roots, :locals => {:link_name => "title", :url_path => "setting" }
  end

  batch_action :destroy, false

  member_action :revert do
    @version = PaperTrail::Version.find(params[:id])
    if @version.reify
      @version.reify.save!
    else
      @version.item.destroy
    end
    redirect_to :back, :notice => I18n.t('active_admin.settings.notice.undid_event')
  end

  action_item :only => :edit do
    if resource.versions.last
      link_to("Undo", revert_admin_setting_path(:id => resource.versions.last), :class => "undo")
    end
  end
  action_item only: [:edit, :show] do
    render partial: '/goldencobra/admin/shared/prev_item'
  end

  action_item only: [:edit, :show] do
    render partial: '/goldencobra/admin/shared/next_item'
  end

end
