module ActAsAdmin::Controller
  module BreadCrumb
    extend ActiveSupport::Concern

    included do
      before_filter :breadcrumbs
    end

    def breadcrumbs
      @context.parents.reduce([]) do |parents, resource|
        append_resource_breadcrumbs parents, resource[0], resource[1][:title_field] || :to_s
        parents << resource
      end
      append_breadcrumbs @context.page.breadcrumbs
    end

    private

    def append_resource_breadcrumbs parents, resource, title_field
      resource_name = @context.resource_name(resource)
      resources_url = @context.path_for(:resource=>resource_name, :parents=>parents){|helper, *args| 
        self.send(helper.to_sym, *args)
      }
      resource_url = @context.path_for(:resource=>resource_name, :parents=>parents, :singular=>true){|helper, *args|
        self.send(helper.to_sym, *(args+[resource]))
      }

      add_breadcrumb resource.class.model_name.human, resources_url
      add_breadcrumb resource.send(title_field), resource_url
    end

    def append_breadcrumbs breadcrumbs
      breadcrumbs.each_pair do |name, opts|
        link = opts[:link]
        if (link.is_a? Proc)
          path = self.instance_exec(&link)
          next if path.nil?
          if (path.respond_to? :each)
            name = path[0];
            path=path[1]
          end
        end
        add_breadcrumb *[name, path].compact
      end
    end

  end
end
