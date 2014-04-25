ActiveAdmin::Dashboards.build do

  # Define your dashboard sections here. Each block will be
  # rendered on the dashboard in the context of the view. So just
  # return the content which you would like to display.

  # == Simple Dashboard Section
  # Here is an example of a simple dashboard section
  #
   section I18n.t('active_admin.dashboard.section'), priority: 1, :if => proc{can?(:update, Goldencobra::Article)} do
    table do
      tr do
        ["Titel", "Erstellt am", ""].each do |sa|
          th sa
        end
      end

      Goldencobra::Article.recent(5).collect do |article|
        tr do
          td article.title
          td l(article.created_at, format: :short)
          result = link_to(t(:view), article.public_url, :class => "member_link edit_link view", :title => I18n.t('active_admin.dashboard.title1'), :target => "_blank")
          result += link_to(t(:edit), admin_article_path(article), :class => "member_link edit_link edit", :title => I18n.t('active_admin.dashboard.title2'))
          result += link_to(t(:new_subarticle), new_admin_article_path(:parent => article), :class => "member_link edit_link new_subarticle", :title => I18n.t('active_admin.dashboard.title3'))
          td result
        end
      end
    end
    
    table do
      tr do
        td link_to(I18n.t('active_admin.dashboard.table.link'), admin_article_path("new"))
      end
    end
   end

   section I18n.t('active_admin.dashboard.widget_section'), priority: 2, :if => proc{can?(:update, Goldencobra::Widget)} do
    table do
      tr do
        ["Titel", "Erstellt am", ""].each do |sa|
          th sa
        end
      end

      Goldencobra::Widget.recent(5).collect do |widget|
        tr do
          td widget.title
          td l(widget.created_at, format: :short)
          td link_to(t(:edit), admin_widget_path(widget), :class => "member_link edit_link edit", :title => I18n.t('active_admin.dashboard.title4'))
        end
      end
    end
   end

  # == Render Partial Section
  # The block is rendered within the context of the view, so you can
  # easily render a partial rather than build content in ruby.
  #
  #   section "Recent Posts" do
  #     div do
  #       render 'recent_posts' # => this will render /app/views/admin/dashboard/_recent_posts.html.erb
  #     end
  #   end

  # == Section Ordering
  # The dashboard sections are ordered by a given priority from top left to
  # bottom right. The default priority is 10. By giving a section numerically lower
  # priority it will be sorted higher. For example:
  #
  #   section 'last_updated_articles', :priority => 1
  #   section "Recent User", :priority => 1
  #
  # Will render the "Recent Users" then the "Recent Posts" sections on the dashboard.

end
