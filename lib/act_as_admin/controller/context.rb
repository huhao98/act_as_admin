module ActAsAdmin::Controller
  class Context
    
    attr_reader :config, :page, :query, :form, :action
    attr_reader :parents
    delegate :model, :resource, :to=>:config

    def initialize config, params
      @action = params[:action].to_sym

      @config = config
      @page = config.pages[@action] || config.default_page
      @query = config.queries[@action]
      @form = config.forms[@action]
      @parents = find_parents params     
    end

    def fields
      resource.fields.each_pair do |name, opts|
        next unless (opts[:when] || action) == action
        if parent.present? && opts[:parent_class] == parent.class
          yield(name, parent) 
        else
          yield(name, opts[:value]) 
        end
      end
    end

    def path_for opts={}
      name = opts.delete(:resource) || resource_name
      name = name.to_s.pluralize unless opts.delete(:singular)

      p = opts.delete(:parents) || self.parents.keys
      action = opts.delete(:action)
      parent_names = p.collect{|p| resource_name p}
      args = p

      helper_method=[action, parent_names, name, "path"].flatten.compact.join("_").to_sym
      yield(helper_method, *args) if block_given?
    end

    def find_from
      return resource.query_from_proc if resource.query_from_proc.present?
      return model.all unless parent.present?
      return parent.send(parents[parent][:on].to_sym)
    end

    def exclude_nested_index?
      (config.opts[:exclude_nested_index] || false) && parent.present?
    end

    def parent
      @parent ||= parents.keys.last
      return @parent
    end

    def parent_name
      return resource_name parent if parent
    end

    def resource_name parent = nil
      return parents[parent][:resource_name] unless parent.nil?
      return config.resource_name
    end

    private 

    def find_parents params
      parents = Hash.new
      resource.parents.reduce(parents) do |memo, pair|
        parent = memo.keys.last
        parent_name, opt = parent_config pair[0], pair[1], params

        find_from = parent ? parent.send(memo[parent][:on].to_sym) : opt[:model]
        id = params["#{parent_name}_id".to_sym]
        memo[find_from.find(id)] = {:on=>opt[:on], :resource_name=>parent_name, :title_field=>opt[:title_field]}.select{|k,v| v.present?} if (id)
        memo
      end if resource.parents

      return parents
    end

    def parent_config parent_key, opts, params
      return [parent_key, opts] if opts[:parents].nil?
      opts[:parents].select do |parent_key, opts|
        params["#{parent_key}_id".to_sym].present?
      end.first.flatten
    end

  end
end