module ActAsAdmin::Controller
  module BreadCrumb
    extend ActiveSupport::Concern

    included do
      before_filter :breadcrumbs
    end

    def breadcrumbs
      @context.nav do |parents, resource_name, component_opts|
        names = parents.keys << resource_name
        exclude = component_opts[:exclude] || []
        namespace = component_opts[:namespace] || []

        unless (component_opts[:collection].nil? || exclude.include?(:index))
          append_collection_breadcrumb(namespace, names, parents.values, component_opts)
        end

        resource = component_opts[:resource]
        unless (resource.nil? || exclude.include?(:show))
          append_resource_breadcrumb(namespace, names, resource, parents.values, component_opts)
        end
      end

      if @context.page.breadcrumbs.present?
        @context.page.breadcrumbs.each do |proc|
          self.instance_exec(&proc)
        end
      end

    end

    private 

    def append_collection_breadcrumb namespace, names, parents, opts
      helper = ([namespace] + names).flatten.compact.join("_").pluralize
      url = self.send("#{helper}_path".to_sym, *parents)

      model_class = opts[:model] || names.last.to_s.singularize.classify.constantize
      add_breadcrumb model_class.model_name.human, url
    end

    def append_resource_breadcrumb namespace, names, resource, parents, opts
      helper = ([namespace] + names).flatten.compact.join("_").singularize
      args = parents << resource
      url = self.send("#{helper}_path".to_sym, *args)

      title_field = opts[:title] || :to_s
      title = resource.send(title_field.to_sym)
      add_breadcrumb title, url
    end


  end
end
