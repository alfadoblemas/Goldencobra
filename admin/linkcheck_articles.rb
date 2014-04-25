ActiveAdmin.register_page "LinkCheckers" do
  menu false
  controller.authorize_resource :class => Goldencobra::Article

  action_item :only => :index do
    link_to(I18n.t('active_admin.linkcheck_articles.link_to.run'), run_all_link_checker_admin_seo_articles_path())
  end

	content do
  	div do
    	render :partial => "goldencobra/admin/articles/link_checker_index"
    end
  end

end