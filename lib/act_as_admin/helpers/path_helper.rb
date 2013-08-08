module ActAsAdmin::Helpers
  module PathHelper

    def new_resource_path params=nil
      path params, :action=>:new, :singular=>true
    end

    def edit_resource_path resource, params=nil
      path params, :action=>:edit, :singular=>true, :resource=>resource
    end

    def resource_path resource, params=nil
      path params, :singular=>true, :resource=>resource
    end

    def resources_path params=nil
      path params
    end

    def redirect_to_resources_path params=nil
      path params do |helper_components, args, params, opts|
        if (opts[:exclude] || []).include? :index
          helper_components.slice!(-1)
        end
        args = (args + [params]).flatten.compact
        self.send (helper_components + ["path"]).join("_"), *args
      end
    end

    def child_resource_path resource, child_name, child, params=nil
      child_path resource, params, :singular=>true, :child_name=>child_name, :child=>child
    end

    def child_resources_path resource, child_name, params=nil
      child_path resource, params, :singular=>false, :child_name=>child_name
    end

    def new_child_resource_path resource, child_name, params=nil
      child_path resource, params, :action=>:new, :singular=>true, :child_name=>child_name
    end

    def edit_child_resource_path resource, child_name, child, params=nil
      child_path resource, params, :action=>:edit, :singular=>true, :child_name=>child_name, :child=>child
    end

    def child_path resource, params, opts={}
      child_name = opts.delete(:child_name)
      child = opts.delete(:child)
      singular = opts.delete(:singular)

      path(params, opts.merge(:singular=>true, :resource=>resource)) do |helper_components, args, params, opts|
        child_name = singular ? child_name.to_s.singularize : child_name.to_s.pluralize
        helper_components << child_name
        args = (args + [child] + [params]).flatten.compact
        self.send (helper_components + ["path"]).join("_"), *args
      end
    end

    def path params, opts={}, &block
      @context.resources do |parents, resource_name, resource_opts|
        action = opts[:action]
        path_name = opts[:singular] == true ? resource_name.to_s.singularize : resource_name.to_s.pluralize
        namespace = resource_opts[:namespace]
        helper_components = ([action] + [namespace] + parents.keys + [path_name]).flatten.compact
        args = (parents.values + [opts[:resource]]).flatten.compact

        if (block_given?)
          yield(helper_components, args, params, resource_opts)
        else
          args = (args + [params]).compact
          self.send (helper_components + ["path"]).join("_"), *args
        end
      end
    end



  end
end
