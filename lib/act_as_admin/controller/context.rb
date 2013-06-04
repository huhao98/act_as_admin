module ActAsAdmin::Controller
  class Context
    
    attr_reader :config, :action, :page, :resource_components
    delegate :model, :resource_name, :resource_config, :to=>:config
    delegate  :nav, :resource, :collection, :resources, :resource_title, :root_resource_name, :to=>:resource_components

    def initialize config, params
      @action = params[:action].to_sym
      @page = config.pages[@action]

      case @action
      when :create
        @page ||= config.pages[:new]
      when :update
        @page ||= config.pages[:edit]
      end

      @page ||= ActAsAdmin::Builder::PageConfig.new
      @config = config
      
      @resource_components = resource_config.resource_components(params)
    end

    def lists 
      return unless page.lists.present?
      page.lists.keys.collect{|name| list(name)}
    end

    def named_lists &block
      page.lists.except(:default).each do |name, list_config|
        yield(name, list(name))
      end
    end

    def list name=nil
      return unless page.lists.present?
      name ||= :default

      list_config = page.lists[name]
      formatters = resource_config.find_formatters(
        :scope=> list_config.opts[:scope], 
        :fields=> list_config.opts[:fields], 
        :action=> action
      )
      ActAsAdmin::Components::List.new(formatters, list_config)
    end

    def forms
      page.forms.keys.collect{|name| form name}
    end

    def form name=nil
      name ||= :default
      form_config = page.forms[:default]
      input_fields = resource_config.find_inputs form_config.fields
      ActAsAdmin::Components::Form.new(input_fields, form_config)
    end
    
  end
end