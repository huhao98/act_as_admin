module Admin::Helpers
  module NavHelper
    class << self
      attr_reader :config

      def append opts={}
        @config ||= []
        @config <<opts
      end

      def nav_items
        results = {:items=>[], :groups=>{}}
        config.reduce(results) do |results, item|
          if item[:group]
            title = item[:group]
            results[:groups][title] ||= []
            results[:groups][title] << item
          else
            results[:items] << item
          end
          results
        end

        groups = results[:groups].collect do |title, group|
          memo = {:models=>[]}
          group.reduce(memo) do |memo, v|
            memo[:models] << v[:model]
            memo[:i] = [memo[:i], v[:i]].compact.min
            memo
          end
          memo.merge(:title=>title)
        end

        nav_items = (groups + results[:items]).sort_by{|item| item[:i]}
      end
    end

    

    def admin_nav_items nav_items=[]
      ::Admin::Helpers::NavHelper.nav_items.each do |ni|
        concat(model_nav_item(ni[:model])) if ni[:model].present?
        concat(models_nav_item(ni[:title], ni[:models])) if ni[:models].present?
        concat(nav_item(ni[:title], ni[:url])) if ni[:url].present?
      end
    end

    private
    def nav_item title, url, active=nil
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
