module ActAsAdmin::Helpers
  
  module NavHelper
    def admin_nav_items
      Rails.configuration.nav.nav_items.each do |ni|
        concat(model_nav_item(ni[:model])) if ni[:model].present?
        concat(models_nav_item(ni[:title], ni[:models])) if ni[:models].present?
        concat(nav_item(ni[:title], ni[:url])) if ni[:url].present?
      end
    end

    private
    def nav_item title, url, active=nil
      url = instance_exec(&url) if url.is_a?(Proc)
      active = active || (url == url_for(:controller=>params[:controller], :action=>params[:action]))      
      opts = {:class=>:active} if active
      content_tag :li, link_to(title, url), opts
    end

    def model_nav_item model
      path = to_resource_path({:resource=>model_name(model).pluralize}, [])
      nav_item(model.model_name.human, path, (model == @model))
    end

    def models_nav_item title, models
      cls = :active unless models.select{|m| m==@model}.empty?
      bootstrap_dropdown_menu(title, cls) {models.each{|model| concat(model_nav_item(model))}}
    end
  end
end
