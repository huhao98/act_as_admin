module Admin::Controller
  module ResourceFilters
    extend ActiveSupport::Concern
    
    included do
      before_filter :find_parents
      before_filter :new_resource, :only=>[:new, :create]
      before_filter :find_resource, :only=>[:show, :destroy, :edit, :update]
      before_filter :find_resources
      before_filter :breadcrumbs
    end

    def find_parents
      admin_config = self.class.admin_config
      parents = Hash.new
      admin_config.parents.reduce(parents) do |memo, pair|                
        model_key = pair[0]
        parent = memo.keys.last

        model = model_key.respond_to?(:size)? model_key.select {|m| params["#{model_name(m)}_id".to_sym].present?}.first : model_key
        find_from = parent ? parent.send(memo[parent][:on].to_sym) : model
        
        id = params["#{model_name(model)}_id".to_sym]       
        memo[find_from.find(id)] = {:on=>pair[1][:on]}
        memo
      end

      @parents = parents
    end        

    def new_resource     
      @resource = @model.new(params[singular_name.to_sym])
      parent = @parents.keys.last

      if (parent)
        @resource.send("#{parent_field}=", parent)
      end
    end

    def find_resource
      @resource = query_root.find(params[:id])
    end

    def find_resources
      return unless @query
      @resources = query_by(@query, :from => query_root)
      instance_variable = @query.as
      self.instance_variable_set("@#{instance_variable}", @resources) if instance_variable
    end

    def breadcrumbs
      parents=[]
      @parents.each_pair do |parent, opts|        
        title_field = opts[:title_field] || :name || :title || :to_s
        parent_name = model_name(parent.class)
        add_breadcrumb parent.class.model_name.human, to_resource_path({:resource=>parent_name.pluralize}, parents)
        add_breadcrumb parent.send(title_field), to_resource_path({:resource=>parent_name, :args=>[parent]}, parents)
        parents << parent
      end

      @page.breadcrumbs.each_pair do |name, opts|
        path = self.instance_exec(&opts[:path]) if opts[:path]
        title = self.instance_exec(&name) if (name.is_a?(Proc))
        add_breadcrumb title || name, path
      end
    end


    private 
    def query_root
      return @model.all unless @parents.present?

      parent = @parents.keys.last
      children_collection = @parents[parent][:on] || plural_name
      parent.send(children_collection.to_sym)
    end

    def parent_field
      return parent_name
    end

  end
end
