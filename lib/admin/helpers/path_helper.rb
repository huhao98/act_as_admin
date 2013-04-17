module Admin::Helpers
  module PathHelper

    def new_resource_path params={}
      to_resource_path :action=>:new, :resource=>singular_name, :params=>params
    end

    def edit_resource_path resource, params={}
      to_resource_path :action=>:edit, :resource=>singular_name, :params=>params, :args=>[resource]
    end

    def resource_path resource, params={}
      to_resource_path :resource=>singular_name, :params=>params, :args=>[resource]
    end

    def resources_path params={}
      to_resource_path :resource=>plural_name, :params=>params
    end

    def to_resource_path opts={}, parents = nil
      parents = parents || @parents.keys
      action = opts.delete(:action)
      resource = opts.delete(:resource)
      parent_names = parents.collect{|p| model_name p.class}
      helper_method=[action, parent_names, resource, "path"].flatten.compact.join("_").to_sym

      args = opts.delete(:args) || []
      params = opts.delete(:params) || {}  
      args.unshift(*parents).compact!
      args << params

      self.send helper_method, *args
    end


    def plural_name
      singular_name.pluralize
    end

    def singular_name
      model_name @model 
    end

    def parent_name
      parent = @parents.keys.last
      return unless parent
      
      model_name parent.class
    end

    def model_name model_class
      model_class.model_name.split(/:+/).last.underscore
    end

    
  end
end
