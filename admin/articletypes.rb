# encoding: utf-8

ActiveAdmin.register Goldencobra::Articletype, :as => "Articletype" do
  menu :priority => 2, :parent => "Content-Management", :if => proc{can?(:update, Goldencobra::Article)}
  controller.authorize_resource :class => Goldencobra::Article
  config.clear_action_items!

  index do
    selectable_column
    column :name
    column :default_template_file
    default_actions
  end

  form :html => { :enctype => "multipart/form-data" }  do |f|
    f.inputs "Allgemein" do
      f.input :default_template_file, :as => :select, :collection => Goldencobra::Article.templates_for_select, :include_blank => false
    end
    f.inputs "Artikel Felder", :class => "foldable closed inputs" do
      f.has_many :fieldgroups do |fg|
        fg.input :title
        fg.input :position, :as => :select, :collection => [["First Block","first_block"],["Last Block","last_block"]], :include_blank => false, :hint => "Zwischen dem ersten und dem letzten Block kommen die speziellen Feldoptionen eines Articeltypen"
        fg.input :foldable, :hint => "Kann man den Bereich auf und zu klappen?"
        fg.input :closed, :hint => "Ist der Bereich beim laden geöffnet oder geschlossen"
        fg.input :expert, :hint => "Ist der Bereich nur im Expertenmodus sichtbar"
        fg.input :sorter, :hint => "Sortiernummer/Position"
        fg.input :_destroy, :as => :boolean
        fg.has_many :fields do |fo|
          fo.input :fieldname, :as => :select, :collection => Goldencobra::Articletype::ArticleFieldOptions.keys, :include_blank => false
          fo.input :sorter
          fo.input :_destroy, :as => :boolean
        end
      end
    end
    if f.object.present? && !f.object.new_record? && File.exists?("#{::Rails.root}/app/views/articletypes/#{f.object.name.underscore.parameterize.downcase}/_edit_articletype.html.erb")
      render :partial => "articletypes/#{f.object.name.underscore.parameterize.downcase}/edit_articletype", :locals => {:f => f}
    end
	  Rails::Application::Railties.engines.select{|a| a.engine_name.include?("goldencobra")}.each do |engine|
	  	if File.exists?("#{engine.root}/app/views/layouts/#{engine.engine_name}/_edit_articletype.html.erb")
	  	  render :partial => "layouts/#{engine.engine_name}/edit_articletype", :locals => {:f => f, :engine => engine}
	  	end
		end
    f.actions
  end

end