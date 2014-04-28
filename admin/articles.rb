#Encoding: UTF-8
ActiveAdmin.register Goldencobra::Article, :as => "Article" do 
  menu :priority => 1, :parent => "Content-Management", :if => proc{can?(:update, Goldencobra::Article)} 
  controller.authorize_resource :class => Goldencobra::Article
  unless Rails.env == "test" 
    I18n.locale = :de
    I18n.default_locale = :de
  end

  #Alle Filteroptionen in der rechten Seitenleiste
  filter :parent_ids_in, :as => :select, :collection => proc { Goldencobra::Article.order("title") }, :label => I18n.t("filter_parent", :scope => [:goldencobra, :filter], :default => "Elternelement")
  filter :article_type, :as => :select, :collection => Goldencobra::Article.article_types_for_select.map{|at| [I18n.t(at.parameterize.underscore.downcase, scope: [:goldencobra, :article_types], default: at), at]}.sort, :label => I18n.t("filter_type", :scope => [:goldencobra, :filter], :default => "Artikeltyp")
  filter :title, :label => I18n.t("filter_titel", :scope => [:goldencobra, :filter], :default => "Titel")
  filter :frontend_tag_name, :as => :string, :label => I18n.t("frontend_tags", :scope => [:goldencobra, :filter], :default => "Filterkriterium")
  filter :tag_name, :as => :string, :label => I18n.t("tags", :scope => [:goldencobra, :filter], :default => "Interne Tags")
  #filter :subtitle, :label =>  I18n.t("filter_subtitel", :scope => [:goldencobra, :filter], :default => "Unteritel")
  #filter :breadcrumb, :label =>  I18n.t("filter_breadcrumb", :scope => [:goldencobra, :filter], :default => "Brotkruemel")
  filter :url_name, :label =>  I18n.t("filter_url", :scope => [:goldencobra, :filter], :default => "Website")
  #filter :template_file, :label =>  I18n.t("filter_template", :scope => [:goldencobra, :filter], :default => "Template Datei")
  filter :created_at, :label =>  I18n.t("filter_created", :scope => [:goldencobra, :filter], :default => "Erstellt")
  filter :updated_at, :label =>  I18n.t("filter_updated", :scope => [:goldencobra, :filter], :default => "Bearbeitet")


  scope "Alle", :scoped, :default => true
  scope "Online", :active
  scope "Offline", :inactive

  Goldencobra::Article.article_types_for_select.each do |article_type|
    next if article_type.include?("index")
    scope(I18n.t(article_type.split(' ').first.to_s.strip, :scope => [:goldencobra, :article_types], :default => article_type.split(' ').first)){ |t| t.where("article_type LIKE '%#{article_type.split(' ').first}%'") }
  end

  form :html => { :enctype => "multipart/form-data" }  do |f|
    if f.object.new_record?
      render :partial => "/goldencobra/admin/articles/select_article_type", :locals => {:f => f}
    else
      f.actions
<<<<<<< HEAD
      f.inputs I18n.t('active_admin.articles.form.general'), :class => "foldable inputs" do
        f.input :title, :label => I18n.t('active_admin.articles.form.title_label'), :hint => I18n.t('active_admin.articles.form.label_hint')
        f.input :content, :label => I18n.t('active_admin.articles.form.content_title'), :input_html => { :class => "tinymce" }
        f.input :teaser, :hint => I18n.t('active_admin.articles.form.teaser_hint') , :input_html => { :rows => 5 }
        f.input :tag_list, :label => I18n.t('active_admin.articles.form.tag_list_label'), :hint => I18n.t('active_admin.articles.form.tag_list_hint'), :wrapper_html => { class: 'expert' }
        f.input :frontend_tag_list, label: I18n.t('active_admin.articles.form.frontent_tag_list_label'), hint: I18n.t('active_admin.articles.form.frontent_tag_list_hint') , :wrapper_html => { class: 'expert' }
        f.input :active, :label => I18n.t('active_admin.articles.form.active_label') , :hint => I18n.t('active_admin.articles.form.active_hint'), :wrapper_html => { class: 'expert' }
=======
      #Render alle Feldgruppen und Felder mit Position "first"
      if f.object.articletype.present?
       f.object.articletype.fieldgroups.where(:position => "first_block").each do |atg|
         f.inputs atg.title, :class => "#{atg.foldable ? 'foldable' : ''} #{atg.expert ? 'expert' : ''} #{atg.closed ? 'closed' : ''} inputs" do
           atg.fields.each do |atgf|
             render(:inline => Goldencobra::Articletype::ArticleFieldOptions[atgf.fieldname.to_sym], :locals => { :f => f })
           end
           f.input :id, :as => :hidden
         end
       end
>>>>>>> translations3
      end

      #render Show Options if articletype == Show
      if f.object.article_type.present? && f.object.kind_of_article_type.downcase == "show"

        #render Article_type Options
        if File.exists?("#{::Rails.root}/app/views/articletypes/#{f.object.article_type_form_file.underscore.parameterize.downcase}/_edit_show.html.erb")
          render :partial => "articletypes/#{f.object.article_type_form_file.underscore.parameterize.downcase}/edit_show", :locals => {:f => f}
        else
          f.inputs I18n.t('active_admin.articles.error.partial_missing') do
<<<<<<< HEAD
=======
          end
        end

        #render goldencobra_module options
        Rails::Application::Railties.engines.select{|a| a.engine_name.include?("goldencobra")}.each do |engine|
          if File.exists?("#{engine.root}/app/views/layouts/#{engine.engine_name}/_edit_show.html.erb")
            render :partial => "layouts/#{engine.engine_name}/edit_show", :locals => {:f => f, :engine => engine}
>>>>>>> translations3
          end
        end

      #render Index Options if articletype == Index
      elsif f.object.kind_of_article_type.downcase == "index"
        render :partial => "goldencobra/admin/articles/articles_index", :locals => {:f => f}
        if File.exists?("#{::Rails.root}/app/views/articletypes/#{f.object.article_type_form_file.underscore.parameterize.downcase}/_edit_index.html.erb")
          render :partial => "articletypes/#{f.object.article_type_form_file.underscore.parameterize.downcase}/edit_index", :locals => {:f => f}
        else
          f.inputs I18n.t('active_admin.articles.error.partial_missing2') do
          end
        end
<<<<<<< HEAD
        #render :partial => "goldencobra/admin/articles/sort_articles_index", :locals => {:f => f}
      else
        #error
      end
      f.inputs I18n.t('active_admin.articles.form.weiterer_inhalt'), :class => "foldable closed inputs" do
        f.input :subtitle, :label => I18n.t('active_admin.articles.form.subtitle_label')
        f.input :context_info, :label => I18n.t('active_admin.articles.form.weiterer_inhalt'), :input_html => { :class => "tinymce" }, :hint => I18n.t('active_admin.articles.form.context_info_hint')
        f.input :summary, :label => I18n.t('active_admin.articles.form.summary_label'), hint: I18n.t('active_admin.articles.form.summary_hint'), :input_html => { :rows => 5 }
      end
      f.inputs I18n.t('active_admin.articles.form.metadescriptions'), :class => "foldable closed inputs expert" do
        # f.input :hint_label, :as => :text, :label => "Metatags fuer Suchmaschinenoptimierung", :input_html => {:disabled => true,
          # :resize => false,
          # :value => "<b>Metatags k&ouml;nnen genutzt werden, um den Artikel f&uuml;r Suchmaschinen besser sichtbar zu machen.</b><br />
          # Sie haben folgende Werte zur Wahl:<br />
          # <ul>
          # <li><strong>Title Tag:</strong> Der Title der Seite. Wird nicht als Titel angezeigt. Ist nur f&uuml;r Google & Co. gedacht. </li>
          # <li><strong>Metadescription:</strong> Wird als Beschreibung des Artikels angezeigt, wenn Google ihn gefunden hat. <strong>Wichtig!</strong></li>
          # <li><strong>Keywords:</strong></li>
          # <li><strong>OpenGraph Title:</strong> Title, der bei Facebook angezeigt werden soll, wenn der Artikel geteilt wird.</li>
          # <li><strong>OpenGraph Description:</strong> Description, die bei Facebook angezeigt werden soll, wenn der Artikel geteilt wird.</li>
          # <li><strong>OpenGraph Type:</strong> Sie haben die Wahl zwischen Blog, Article oder Website</li>
          # <li><strong>OpenGraph URL:</strong> Die URL der Website. Standardm&auml;&szlig; wird die URL des Artikels genutzt. Muss nur ver&auml;ndert werden, wenn dort etwas anderes stehen soll.</li>
          # <li><strong>OpenGraph Image:</strong> Muss als URL &uuml;bergeben werden (http://www.mein.de/bild.jpg). Erscheint dann bei Facebook als Bild des Artikels.</li>
          # </ul>", :class => "metadescription_hint", :id => "metadescription-tinymce"}
        f.has_many :metatags do |m|
          m.input :name, :label => I18n.t('active_admin.articles.form.name_label'), :as => :select, :collection => Goldencobra::Article::MetatagNames, :input_html => { :class => 'metatag_names'}, :hint => I18n.t('active_admin.articles.form.name_hint')
          m.input :value, :label => I18n.t('active_admin.articles.form.value_label'), :input_html => { :class => 'metatag_values'}
          m.input :_destroy, :label => I18n.t('active_admin.articles.form.destroy_label'), :hint => I18n.t('active_admin.articles.form.destroy_hint'), :as => :boolean
        end
      end
      f.inputs I18n.t('active_admin.articles.form.settings'), :class => "foldable closed inputs expert" do
        f.input :breadcrumb, :label => I18n.t('active_admin.articles.form.breadcrump_label'), :hint => I18n.t('active_admin.articles.form.breadcrump_hint')
        f.input :url_name, :label => I18n.t('active_admin.articles.form.url_name_label'), :hint => I18n.t('active_admin.articles.form.url_name_hint'), required: false
        f.input :parent_id, :label => I18n.t('active_admin.articles.form.parent_id_label'), :hint => I18n.t('active_admin.articles.form.parent_id_hint'), :as => :select, :collection => Goldencobra::Article.all.map{|c| ["#{c.path.map(&:title).join(" / ")}", c.id]}.sort{|a,b| a[0] <=> b[0]}, :include_blank => true, :input_html => { :class => 'chzn-select-deselect', :style => 'width: 70%;', 'data-placeholder' => 'Elternelement auswählen' }
        f.input :canonical_url, :label => I18n.t('active_admin.articles.form.canonical_url_label'), :hint => I18n.t('active_admin.articles.form.canonical_url_hint')

        f.input :active_since, :label => I18n.t('active_admin.articles.form.active_since_label'), :hint => I18n.t('active_admin.articles.form.active_since_hint'), as: :string, :input_html => { class: "", :size => "20", value: "#{f.object.active_since.strftime('%d.%m.%Y %H:%M') if f.object.active_since}" }, :wrapper_html => { class: 'expert' }
        f.input :enable_social_sharing, :label => I18n.t('active_admin.articles.form.enable_social_sharing_label'), :hint => I18n.t('active_admin.articles.form.enable_social_sharing_hint')
        f.input :robots_no_index, :label => I18n.t('active_admin.articles.form.robots_no_index_label'), :hint => I18n.t('active_admin.articles.form.robots_no_index_hint')
        f.input :cacheable, :label => I18n.t('active_admin.articles.form.cacheable_label'), :as => :boolean, :hint => I18n.t('active_admin.articles.form.cacheable_hint')
        f.input :commentable, :label => I18n.t('active_admin.articles.form.commentable_label'), :as => :boolean, :hint => I18n.t('active_admin.articles.form.commentable_hint')
        f.input :dynamic_redirection, :label => I18n.t('active_admin.articles.form.dynamic_redirection_label'), :as => :select, :collection => Goldencobra::Article::DynamicRedirectOptions.map{|a| [a[1], a[0]]}, :include_blank => false
        f.input :external_url_redirect, :label => I18n.t('active_admin.articles.form.external_url_redirect_label')
        f.input :redirect_link_title, :label => I18n.t('active_admin.articles.form.redirect_link_title_label')
        f.input :redirection_target_in_new_window, :label => I18n.t('active_admin.articles.form.redirection_target_in_new_window_label')
        f.input :author, :label => I18n.t('active_admin.articles.form.author_label'), :hint => I18n.t('active_admin.articles.form.author_hint')
      end
      f.inputs I18n.t('active_admin.articles.form.access_rights'), :class => "foldable closed inputs expert" do
        f.has_many :permissions do |p|
          p.input :role, :include_blank => I18n.t('active_admin.articles.form.role')
          p.input :action, :as => :select, :collection => Goldencobra::Permission::PossibleActions, :include_blank => false
          p.input :_destroy, :as => :boolean
=======
        Rails::Application::Railties.engines.select{|a| a.engine_name.include?("goldencobra")}.each do |engine|
          if File.exists?("#{engine.root}/app/views/layouts/#{engine.engine_name}/_edit_index.html.erb")
            render :partial => "layouts/#{engine.engine_name}/edit_index ", :locals => {:f => f, :engine => engine}
          end
>>>>>>> translations3
        end
        #render :partial => "goldencobra/admin/articles/sort_articles_index", :locals => {:f => f}
      end
<<<<<<< HEAD
      f.inputs I18n.t('active_admin.articles.form.media'), :class => "foldable closed inputs" do
        f.has_many :article_images do |ai|
          ai.input :image, :as => :select, :collection => Goldencobra::Upload.order("updated_at DESC").map{|c| [c.complete_list_name, c.id]}, :input_html => { :class => 'article_image_file chzn-select', :style => 'width: 70%;', 'data-placeholder' => 'Medium auswählen' }, :label => "Medium wählen"
          ai.input :position, :as => :select, :collection => Goldencobra::Setting.for_key("goldencobra.article.image_positions").split(",").map(&:strip), :include_blank => false
          ai.input :_destroy, :as => :boolean
        end
      end
    end
    f.inputs I18n.t('active_admin.articles.form.JS_scripts'), :style => "display:none"  do
=======

      #Render alle Feldgruppen und Felder mit Position "last"
      if f.object.articletype.present?
       f.object.articletype.fieldgroups.where(:position => "last_block").each do |atg|
         f.inputs atg.title, :class => "#{atg.foldable ? 'foldable' : ''} #{atg.expert ? 'expert' : ''} #{atg.closed ? 'closed' : ''} inputs" do
           atg.fields.each do |atgf|
             render(:inline => Goldencobra::Articletype::ArticleFieldOptions[atgf.fieldname.to_sym], :locals => { :f => f })
           end
           f.input :id, :as => :hidden
         end
       end
      end
    end

    f.inputs "JS-Scripts", :style => "display:none"  do
>>>>>>> translations3
      if current_user && current_user.enable_expert_mode == true
        render partial: '/goldencobra/admin/articles/toggle_expert_mode'
      end
    end
    f.actions
  end

  index do
    selectable_column
    column "Website-Titel", :sortable => :url_name do |article|
      content_tag("span", link_to(truncate(article.url_name, :length => 40), edit_admin_article_path(article.id), :class => "member_link edit_link"), :class => article.startpage ? "startpage" : "")
    end
    column "Website-Adresse", :url do |article|
      article.public_url
    end
    column "Aktiv?", :active, :sortable => :active do |article|
      link_to(article.active ? "online" : "offline", set_page_online_offline_admin_article_path(article), :title => "#{article.active ? 'Artikel offline stellen' : 'Artikel online stellen'}", :confirm => I18n.t("online", :scope => [:goldencobra, :flash_notice]), :class => "member_link edit_link #{article.active ? 'online' : 'offline'}")
    end
    column "Artikeltyp", :article_type, sortable: :article_type do |article|
      article.article_type.blank? ? "Standard" : I18n.t(article.article_type.parameterize.underscore.downcase, scope: [:goldencobra, :article_types])
    end
    column "Zugriff" do |article|
      Goldencobra::Permission.restricted?(article) ? raw("<span class='secured'>beschränkt</span>") : ""
    end
    #column :created_at, sortable: :created_at do |article|
    #  l(article.created_at)
    #end
    #column :updated_at, sortable: :updated_at do |article|
    #  l(article.updated_at)
    #end
    column I18n.t("menue", :scope => [:goldencobra, :menue]) do |article|
      if article.linked_menues.count > 0
        link_to(I18n.t("list", :scope => [:goldencobra, :menue]), admin_menues_path("q[target_contains]" => article.public_url), :class => "list", :title => "Menüpunkte auflisten")
      else
        link_to(I18n.t("create", :scope => [:goldencobra, :menue]), new_admin_menue_path(:menue => {:title => article.parsed_title, :target => article.public_url}), :class => "create", :title => "Menüpunkt zum Artikel erzeugen")
      end
    end
    column "" do |article|
      result = ""
      result += link_to(t(:view), article.public_url, :class => "member_link edit_link view", :title => "Vorschau des Artikels")
      result += link_to(t(:edit), edit_admin_article_path(article.id), :class => "member_link edit_link edit", :title => "Artikel bearbeiten")
      result += link_to(t(:new_subarticle), new_admin_article_path(:parent => article), :class => "member_link edit_link new_subarticle", :title => "Neuen Unterartikel erstellen")
      result += link_to(t(:delete), admin_article_path(article.id), :method => :DELETE, :confirm => t("delete_article", :scope => [:goldencobra, :flash_notice]), :class => "member_link delete_link delete", :title => "Artikel löschen")
      raw(result)
    end
  end

  action_item :only => [:index] do
    link_to(I18n.t('active_admin.articles.sidebar.seo_link'), admin_seo_articles_path())
  end

  sidebar :overview, only: [:index] do
    render :partial => "/goldencobra/admin/shared/overview", :object => Goldencobra::Article.order(:url_name).roots, :locals => {:link_name => "url_name", :url_path => "article", :order_by => "url_name" }
  end

  sidebar :widgets_options, only: [:edit] do
    render "/goldencobra/admin/articles/widgets_sidebar", :locals => { :current_article => resource }
  end

  sidebar :startpage_options, :only => [:show, :edit] do
    if resource.startpage
      t("startpage", :scope => [:goldencobra, :flash_notice])
    else
      link_to t("action_Startpage", :scope => [:goldencobra, :flash_notice]) , mark_as_startpage_admin_article_path(resource.id), :confirm => t("name_of_flashnotice", :scope => [:goldencobra, :flash_notice])
    end
  end

  sidebar "layout", only: [:edit] do
    render "/goldencobra/admin/articles/layout_sidebar", :locals => { :current_article => resource }
  end

  sidebar :image_module, :only => [:edit] do
    render "/goldencobra/admin/articles/image_module_sidebar"
  end

  sidebar :link_checker, :only => [:edit] do
    render "/goldencobra/admin/articles/link_checker", :locals => { :current_article => resource }
  end

  sidebar :menue_options, :only => [:show, :edit] do
    if resource.linked_menues.count > 0
      h5 I18n.t('active_admin.articles.sidebar.h5')
      div link_to(I18n.t('active_admin.articles.sidebar.div_link'), admin_menues_path("q[target_contains]" => resource.public_url))
      div "oder"
      div link_to(I18n.t('active_admin.articles.sidebar.div_link1'), new_admin_menue_path(:menue => {:title => resource.title, :target => resource.public_url}))
    else
      h5 'active_admin.articles.sidebar.h5'
      div link_to(I18n.t('active_admin.articles.sidebar.div_link2'), new_admin_menue_path(:menue => {:title => resource.title, :target => resource.public_url}))
    end

    articles = Goldencobra::Article.active.where(:url_name => resource.url_name)
    if articles.count > 1
      results = articles.select{|a| a.public_url == resource.public_url}.flatten.compact.uniq
    end

    if results && results.count > 1
      h5 I18n.t('active_admin.articles.sidebar.h5_achtung'), :class => "warning"
      ul do
        results.each do |r|
          next if r == resource
          li link_to "#{r.title}", admin_article_path(r)
        end
      end
    end
  end

  sidebar :help, only: [:edit, :show] do
    render "/goldencobra/admin/shared/help"
  end

  member_action :change_articletype, :method => :post do
    article = Goldencobra::Article.find(params[:id])
    article.article_type = params[:new_article_type]
    if article.article_type.include?("Show")
      unless article.article_type.include?("Default")
        article_model = article.article_type_form_file.constantize
        related_article_object = article_model.where(:article_id => article.id).first
        if related_article_object
          article.send("#{article.article_type_form_file.underscore.parameterize.downcase}=", related_article_object)
        else
          article.send("#{article.article_type_form_file.underscore.parameterize.downcase}=", article_model.new(:article_id => article.id))
        end
        article.save
      end
    end
    article.save
    redirect_to :action => :edit
  end

  member_action :mark_as_startpage do
    article = Goldencobra::Article.find(params[:id])
    article.mark_as_startpage!
    flash[:notice] = I18n.t(:startpage, scope: [:goldencobra, :flash_notice]) #"Dieser Artikel ist nun der Startartikel"
    redirect_to :action => :show
  end

  member_action :set_page_online_offline do
    article = Goldencobra::Article.find(params[:id])
    if article.active
      article.active = false
<<<<<<< HEAD
      flash[:notice] = I18n.t('active_admin.articles.member_action.flash.article_online')
    else
      article.active = true
      flash[:notice] = I18n.t('active_admin.articles.member_action.flash.article_offline')
=======
      flash[:notice] = t("now_offline", :scope => ["active_admin", "articles"])
    else
      article.active = true
      flash[:notice] = t("now_online", :scope => ["active_admin", "articles"])
>>>>>>> translations3
    end
    article.save

    redirect_to :action => :index
  end

  member_action :update_widgets, :method => :post do
    article = Goldencobra::Article.find(params[:id])
    article.update_attributes(:widget_ids => params[:widget_ids])
    redirect_to :action => :edit, :notice => I18n.t('active_admin.articles.member_action.flash.widgets')
  end

  member_action :run_link_checker do
    article = Goldencobra::Article.find(params[:id])
    system("cd #{::Rails.root} && RAILS_ENV=#{::Rails.env} bundle exec rake link_checker:article ID=#{article.id} &")
    flash[:notice] = I18n.t('active_admin.articles.member_action.flash.link_checker')
    redirect_to :action => :edit
  end

  batch_action :reset_cache, :confirm => I18n.t('active_admin.articles.batch_action.cache') do |selection|
    Goldencobra::Article.find(selection).each do |article|
      article.updated_at = Time.now
      article.without_versioning :save
    end
    flash[:notice] = I18n.t('active_admin.articles.batch_action.flash.cache')
    redirect_to :action => :index
  end

  batch_action :set_article_online, :confirm => I18n.t('active_admin.articles.batch_action.confirm_online') do |selection|
    Goldencobra::Article.find(selection).each do |article|
      article.active = true
      article.save
    end
<<<<<<< HEAD
    flash[:notice] = I18n.t('active_admin.articles.batch_action.flash.set_article_online')
=======
    flash[:notice] = I18n.t("now_online", :scope => ["active_admin", "articles"])
>>>>>>> translations3
    redirect_to :action => :index
  end

  batch_action :set_article_offline, :confirm => I18n.t('active_admin.articles.batch_action.confirm_offline')  do |selection|
    Goldencobra::Article.find(selection).each do |article|
      article.active = false
      article.save
    end
<<<<<<< HEAD
    flash[:notice] = I18n.t('active_admin.articles.batch_action.flash.set_article_offline')
=======
    flash[:notice] = I18n.t("now_offline", :scope => ["active_admin", "articles"])
>>>>>>> translations3
    redirect_to :action => :index
  end


  batch_action :destroy, false

  controller do

    def show
      show! do |format|
         format.html { redirect_to edit_admin_article_path(@article.id), :flash => flash }
      end
    end

    def new
      @article = Goldencobra::Article.new(params[:article])
      if params[:parent] && params[:parent].present?
        @parent = Goldencobra::Article.find(params[:parent])
        @article.parent_id = @parent.id
      end
    end
  end

  member_action :toggle_expert_mode do
    current_user.enable_expert_mode = !current_user.enable_expert_mode
    current_user.save
    render template: '/goldencobra/admin/articles/toggle_expert_mode', format: 'js', locals: { enabled: current_user.enable_expert_mode }
  end

  member_action :revert do
    @version = PaperTrail::Version.find(params[:id])
    if @version.reify
      @version.reify.save!
    else
      @version.item.destroy
    end
    redirect_to :back, :notice => I18n.t('active_admin.settings.notice.undid_event')
  end


  action_item only: [:edit, :show] do
    render partial: '/goldencobra/admin/shared/prev_item'
  end

  action_item :only => :edit do
<<<<<<< HEAD
    link_to(I18n.t('active_admin.articles.action_item.link_to.article_preview'), resource.public_url, :target => "_blank")
=======
    link_to(I18n.t("goldencobra.menue.preview_article"), resource.public_url, :target => "_blank")
>>>>>>> translations3
  end

  action_item :only => :edit, :inner_html => {:class => "expert"} do
    link_to(I18n.t('active_admin.articles.action_item.link_to.expert_modus'), toggle_expert_mode_admin_article_path, remote: true, id: "expert-mode")
  end

  action_item :only => :index do
    link_to(I18n.t('active_admin.articles.action_item.link_to.import'), new_admin_import_path(:target_model => "Goldencobra::Article"), :class => "importer")
  end


  action_item :only => :edit do
    if resource.versions.last
      link_to(I18n.t('active_admin.articles.action_item.link_to.undo'), revert_admin_article_path(:id => resource.versions.last), :class => "undo")
    end
  end

  action_item only: [:edit, :show] do
    render partial: '/goldencobra/admin/shared/next_item'
  end
end
