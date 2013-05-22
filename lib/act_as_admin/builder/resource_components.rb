module ActAsAdmin::Builder

  class ResourceComponents
    attr_accessor :components

    def initialize components
      @components = components
    end

    # nav do |parents, resource_name, resource, collection|
    #   resources_url = @context.path_for(:resource=>name, :parents=>parents){|helper, *args|
    #     self.send(helper.to_sym, *args)
    #   }
    #   resource_url = @context.path_for(:resource=>name, :parents=>parents, :singular=>true){|helper, *args|
    #     self.send(helper.to_sym, *(args+[resource]))
    #   }
    #   add_breadcrumb resource.class.model_name.human, resources_url
    #   add_breadcrumb resource.send(title_field), resource_url
    # end
    def nav &block
      components.inject(Hash.new) do |parents, v|
        resource = v[1][:resource]
        resource_name = resource.nil? ? v[0].to_s.pluralize : v[0].to_s.singularize
        yield(parents, resource_name, v[1])
        parents.merge!(resource_name => resource)
      end
    end

    def collection
      components.values.last[:collection]
    end

    def resource
      components.values.last[:resource]
    end

    def resource_title
      title_field = components.values.last[:title_field] || :to_s
      resource.send(title_field.to_sym) if resource
    end

    def parent
      (components.values[-2] || {})[:resource]
    end

    def resource_path opts={}, &block
      resolve_resources(opts.delete(:parents)) do |names, resources|
        helper=[opts[:action], names].flatten.compact.join("_").singularize
        yield("#{helper}_path", *(resources << opts[:resource]).compact)
      end
    end

    def resources_path opts={}, &block
      resolve_resources(opts.delete(:parents)) do |names, resources|
        component_opts = components[names.last.pluralize.to_sym] || {}
        if (components.size > 1 && component_opts[:exclude] || {}).include?(:index) && opts[:action].nil?
          names.slice!(-1)
          helper = names.flatten.compact.join("_").singularize
        else
          helper = [opts[:action], names].flatten.compact.join("_").pluralize
        end

        yield("#{helper}_path", *resources.compact)
      end
    end

    private
    def resolve_resources resources=nil
      resources ||= components.inject(Hash.new) do |parents, v|
        resource = v[1][:resource]
        resource_name = resource.nil? ? v[0].to_s.pluralize : v[0].to_s.singularize
        parents.merge!(resource_name => resource)
      end

      values = resources.values
      values.slice!(-1)
      yield(resources.keys, values)
    end

  end
end
