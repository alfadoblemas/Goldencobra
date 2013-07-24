#encoding: utf-8
ActiveAdmin.register Goldencobra::Menue, :as => "Menue" do

  menu :priority => 2, :parent => "Content-Management", :if => proc{can?(:read, Goldencobra::Menue)}
  controller.authorize_resource :class => Goldencobra::Menue

  filter :title
  filter :target
  filter :css_class
  filter :sorter

  scope :active
  scope :inactive

  form do |f|
    f.actions
    f.inputs "Allgemein" do
      f.input :title
      f.input :target
      f.input :parent_id, :as => :select, :collection => Goldencobra::Menue.all.map{|c| ["#{c.path.map(&:title).join(" / ")}", c.id]}.sort{|a,b| a[0] <=> b[0]}, :include_blank => true
    end
    f.inputs "Optionen", :class => "foldable closed inputs" do
      f.input :sorter, :hint => "Nach dieser Nummer wird sortiert: Je h&ouml;her, desto weiter unten in der Ansicht"
      f.input :active
      f.input :css_class
    end
    f.inputs "Zugriffsrechte", :class => "foldable closed inputs" do
      f.has_many :permissions do |p|
        p.input :role, :include_blank => "Alle"
        p.input :action, :as => :select, :collection => Goldencobra::Permission::PossibleActions, :include_blank => false
        p.input :_destroy, :as => :boolean
      end
    end
    f.inputs "Details", :class => "foldable closed inputs" do
      f.input :image, :as => :select, :collection => Goldencobra::Upload.all.map{|c| [c.complete_list_name, c.id]}, :input_html => { :class => 'article_image_file chzn-select-deselect', :style => 'width: 70%;', 'data-placeholder' => 'Bild auswaehlen' }, :label => "Bild ausw&auml;hlen"
      f.input :description_title
      f.input :description, :input_html => { :rows => 5}
      f.input :call_to_action_name
    end
      f.actions
  end

  index do
    selectable_column
    column :id
    column :title
    column :target
    column :active
    column "Zugriff" do |menue|
      Goldencobra::Permission.restricted?(menue) ? raw("<span class='secured'>beschränkt</span>") : ""
    end
    column :sorter
    column "Artikel" do |menue|
      if menue.mapped_to_article?
        link_to("search", admin_articles_path("q[url_name_contains]" => menue.target.to_s.split('/').last), :class => "list", :title => "Artikel auflisten")
      else
        link_to("create one", new_admin_article_path(:article => {:title => menue.title, :url_name => menue.target.to_s.split('/').last}), :class => "create", :title => "Artikel erzeugen")
      end
    end
    column "" do |menue|
      result = ""
      result += link_to("Edit", edit_admin_menue_path(menue), :class => "member_link edit_link edit", :title => "bearbeiten")
      result += link_to("New Submenu", new_admin_menue_path(:parent => menue), :class => "member_link edit_link", :class => "new_subarticle", :title => "neues Untermenue")
      result += link_to("Delete", admin_menue_path(menue), :method => :DELETE, :confirm => "Realy want to delete this Menuitem?", :class => "member_link delete_link delete", :title => "loeschen")
      raw(result)
    end
  end

  sidebar :overview, only: [:index] do
    render :partial => "/goldencobra/admin/shared/overview", :object => Goldencobra::Menue.order(:title).roots, :locals => {:link_name => "title", :url_path => "menue", :order_by => "title" }
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
    @version = Version.find(params[:id])
    if @version.reify
      @version.reify.save!
    else
      @version.item.destroy
    end
    redirect_to :back, :notice => "Undid #{@version.event}"
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
