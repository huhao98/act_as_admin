module ActAsAdmin::Helpers
  module PathHelper

    def new_resource_path params=nil
      @context.resource_path :action=>:new do |helper_name, *args|
        self.send helper_name, *(args + [params].compact)
      end
    end

    def edit_resource_path resource, params=nil
      @context.resource_path :resource=>resource, :action=>:edit do |helper_name, *args|
        self.send helper_name, *(args + [params].compact)
      end
    end

    def resource_path resource, params=nil
      @context.resource_path :resource=>resource do |helper_name, *args|
        self.send helper_name, *(args + [params].compact)
      end
    end

    def resources_path params=nil
      @context.resources_path do |helper_name, *args|
        self.send helper_name, *(args + [params].compact)
      end
    end
    
  end
end
