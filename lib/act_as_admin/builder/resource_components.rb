module ActAsAdmin::Builder

  class ResourceComponents
    #{
    # :users=>{:resource=>user, :collection=>User.all, :title=>:username},
    # :orders=>{:resource=>order, :collection=user.orders, :title=>:id, :exclude=>[:index]}
    #}
    attr_accessor :components

    def initialize components
      @components = components
    end

    def nav &block
      components.inject(Hash.new) do |parents, v|
        resource = v[1][:resource]
        resource_name = resource.nil? ? v[0].to_s.pluralize : v[0].to_s.singularize
        yield(parents, resource_name, v[1])
        parents.merge!(resource_name => resource)
      end
    end

    # The root resource's name
    def root_resource_name
      components.keys.first.to_s
    end

    # The parent resource
    def parent
      (components.values[-2] || {})[:resource]
    end

    # The collection use to find the resource
    def collection
      components.values.last[:collection]
    end

    # The resource
    def resource
      components.values.last[:resource]
    end

    # Return the resolved title of the current resource
    def resource_title
      title_field = components.values.last[:title] || :to_s
      resource.send(title_field.to_sym) if resource
    end

    # Yield the resource and its options with all the parents
    def resources &block
      rc = components.collect do |resource_name, component|
        [resource_name.to_s.singularize.to_sym, component[:resource], component.slice(:title, :exclude)]
      end
      last = rc.slice!(-1)
      parents = rc.inject(Hash.new){|p, v| p.merge!(v[0]=>v[1])}
      yield(parents, last[0], last[2])
    end   

  end
end
