#encoding: utf-8

ActiveAdmin.register Goldencobra::Menue, :as => "Menue" do
  menu :priority => 2, :parent => "Content-Management", :if => proc{can?(:update, Goldencobra::Menue)}
  controller.authorize_resource :class => Goldencobra::Menue

  filter :title, :label => I18n.t('active_admin.menues.labels.title')
  filter :target, :label => I18n.t('active_admin.menues.labels.target')
  filter :css_class, :label => I18n.t('active_admin.menues.labels.css_class')
  filter :sorter, :label => I18n.t('active_admin.menues.labels.sorter')

  scope "Aktiv", :active
  scope "Nicht aktiv", :inactive

  form do |f|
    f.actions
    f.inputs I18n.t('active_admin.menues.form.generals.general') do
      f.input :title, :label => I18n.t('active_admin.menues.form.generals.title'), :hint => I18n.t('active_admin.menues.form.generals.title_hint')
      f.input :target, :label => I18n.t('active_admin.menues.form.generals.target'), :hint => I18n.t('active_admin.menues.form.generals.target_hint')
      f.input :parent_id, :label => I18n.t('active_admin.menues.form.generals.parent_id'), :hint => I18n.t('active_admin.menues.form.generals.parent_id_hint'), :as => :select, :collection => Goldencobra::Menue.all.map{|c| ["#{c.path.map(&:title).join(" / ")}", c.id]}.sort{|a,b| a[0] <=> b[0]}, :include_blank => true, :input_html => { :class => 'chzn-select-deselect', :style => 'width: 70%;', 'data-placeholder' => 'Elternelement auswählen' }
    end
    f.inputs I18n.t('active_admin.menues.form.options.option'), :class => "foldable closed inputs" do
      f.input :sorter, :label => I18n.t('active_admin.menues.form.options.sorter_label'), :hint => I18n.t('active_admin.menues.form.options.sorter_hint')
      check_box_tag "hidden", :label => I18n.t('active_admin.menues.form.options.checkbox_label'), :hint => I18n.t('active_admin.menues.form.options.checkbox_hint')
      f.input :css_class, :label => I18n.t('active_admin.menues.form.options.css_class_label'), :hint => I18n.t('active_admin.menues.form.options.css_class_hint')
      f.input :active, :label => I18n.t('active_admin.menues.form.options.active_label'), :hint => I18n.t('active_admin.menues.form.options.aktiv_hint')
      f.input :remote, :label => I18n.t('active_admin.menues.form.options.remote_label'), :hint => I18n.t('active_admin.menues.form.options.remote_hint')
    end
    f.inputs I18n.t('active_admin.menues.form.access_rights'), :class => "foldable closed inputs" do
      f.has_many :permissions do |p|
        p.input :role, :include_blank => "Alle"
        p.input :action, :as => :select, :collection => Goldencobra::Permission::PossibleActions, :include_blank => false
        p.input :_destroy, :as => :boolean
      end
    end
    f.inputs "Details für ein erweitertes Menü", :class => "foldable closed inputs" do
      f.input :image, :label => "Bild", :hint => "Bereits hochgeladenes Bild aus der Medienliste wählen", :as => :select, :collection => Goldencobra::Upload.order("updated_at DESC").map{|c| [c.complete_list_name, c.id]}, :input_html => { :class => 'article_image_file chzn-select-deselect', :style => 'width: 70%;', 'data-placeholder' => 'Bild auswählen' }
      f.input :description_title, :label => "Titel", :hint => ""
      f.input :description, :label => "Beschreibung", :hint => "", :input_html => { :rows => 5 }
      f.input :call_to_action_name, :label => "Call-to-action Text", :hint => ""
    end
    f.actions
  end

  index do
    selectable_column
    column "Titel", :title, :sortable => :title do |menue|
      link_to(menue.title, edit_admin_menue_path(menue), :title => "Menüpunkt bearbeiten")
    end
    column "Ziel", :target
    column "Aktiv?", :active, :sortable => :active do |menue|
      raw("<span class='#{menue.active ? 'online' : 'offline'}'>#{menue.active ? 'online' : 'offline'}</span>")
    end
    column "Sortiernr", :sorter
    column "Zugriff" do |menue|
      Goldencobra::Permission.restricted?(menue) ? raw("<span class='secured'>beschränkt</span>") : ""
    end
    column "Artikel" do |menue|
      if menue.mapped_to_article?
        link_to("search", admin_articles_path("q[url_name_contains]" => menue.target.to_s.split('/').last), :class => "list", :title => "Artikel auflisten")
      else
        link_to("create one", new_admin_article_path(:article => {:title => menue.title, :url_name => menue.target.to_s.split('/').last}), :class => "create", :title => "Artikel passend zum Menüpunkt erzeugen")
      end
    end
    column "" do |menue|
      result = ""
      result += link_to("Edit", edit_admin_menue_path(menue), :class => "member_link edit_link edit", :title => "Menüpunkt bearbeiten")
      result += link_to("New Submenu", new_admin_menue_path(:parent => menue), :class => "member_link edit_link", :class => "new_subarticle", :title => "Neuen Untermenüpunkt erzeugen")
      result += link_to("Delete", admin_menue_path(menue), :method => :DELETE, :confirm => "Realy want to delete this Menuitem?", :class => "member_link delete_link delete", :title => "Menüpunkt löschen")
      raw(result)
    end
  end

  sidebar :overview, only: [:index] do
    render :partial => "/goldencobra/admin/shared/overview", :object => Goldencobra::Menue.order(:title).roots, :locals => {:link_name => "title", :url_path => "menue", :order_by => "title" }
  end

  sidebar :help, only: [:edit, :show] do
    render "/goldencobra/admin/shared/help"
  end

  #batch_action :destroy, false

  batch_action :set_menue_offline, :confirm => "Menüpunkt offline stellen: sind Sie sicher?" do |selection|
    Goldencobra::Menue.find(selection).each do |menue|
      menue.active = false
      menue.save
    end
    flash[:notice] = "Menüpunkte wurden offline gestellt"
    redirect_to :action => :index
  end

  batch_action :set_menue_online, :confirm => "Menüpunkt offline stellen: sind Sie sicher?" do |selection|
    Goldencobra::Menue.find(selection).each do |menue|
      menue.active = true
      menue.save
    end
    flash[:notice] = "Menüpunkte wurden online gestellt"
    redirect_to :action => :index
  end

  controller do
    def new
      @menue = Goldencobra::Menue.new(params[:menue])
      if params[:parent] && params[:parent].present?
        @parent = Goldencobra::Menue.find(params[:parent])
        @menue.parent_id = @parent.id
      end
    end
  end

  member_action :revert do
    @version = PaperTrail::Version.find(params[:id])
    if @version.reify
      @version.reify.save!
    else
      @version.item.destroy
    end
    redirect_to :back, :notice => "Undid #{@version.event}"
  end

  batch_action :clone, :confirm => "Do you want to clone this menue" do |selection|
    Goldencobra::Menue.find(selection).each do |menue|
      cloned_parent = Goldencobra::Menue.create(:title => "clone of: #{menue.title}", :target => menue.target, :css_class => menue.css_class, :active => menue.active, :parent_id => menue.parent_id, :sorter => menue.sorter, :description => menue.description, :call_to_action_name => menue.call_to_action_name, :description_title => menue.description_title, :image_id => menue.image_id)
    end
    flash[:notice] = "Menue has been cloned"
    redirect_to :action => :index
  end

  action_item only: [:edit, :show] do
    render partial: '/goldencobra/admin/shared/prev_item'
  end

  action_item :only => :edit do
    if resource.versions.last
      link_to("Undo", revert_admin_menue_path(:id => resource.versions.last), :class => "undo")
    end
  end

  action_item only: [:edit, :show] do
    render partial: '/goldencobra/admin/shared/next_item'
  end

  controller do
    def show
      show! do |format|
         format.html { redirect_to edit_admin_menue_path(@menue), :flash => flash }
      end
    end
  end

end
