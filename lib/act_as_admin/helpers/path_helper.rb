module ActAsAdmin::Helpers
  module PathHelper

    def new_resource_path params=nil
      @context.path_for :action=>:new, :singular=>true do |helper_name, *args|
        self.send helper_name, *(args + [params].compact)
      end
    end

    def edit_resource_path resource, params=nil
      @context.path_for :action=>:edit, :singular=>true do |helper_name, *args|
        self.send helper_name, *(args + [resource, params].compact)
      end
    end

    def resource_path resource, params=nil
      @context.path_for :singular=>true do |helper_name, *args|
        self.send helper_name, *(args + [resource, params].compact)
      end
    end

    def resources_path params=nil
      @context.path_for do |helper_name, *args|
        self.send helper_name, *(args + [params].compact)
      end
    end

    def parent_path params=nil
      parents = @context.parents.keys
      resource = parents.slice!(-1)
      resource_name = @context.resource_name(resource)
      
      @context.path_for(:resource=>resource_name, :parents=>parents, :singular=>true){|helper, *args|
        self.send(helper.to_sym, *(args+[resource]))
      }
    end
  end
end
