module ActAsAdmin::Controller
  class Context
    
    attr_reader :config, :action, :page, :resource_components

    delegate :model, :resource_name, :resource_config, :to=>:config
    delegate :resources_path, :resource_path, :to=>:resource_components

    def initialize config, params
      @action = params[:action].to_sym
      @config = config
      @page = config.pages[@action] || config.default_page
      @resource_components = resource_config.resource_components(params)
    end

    def lists 
      return unless page.lists.present?
      page.lists.keys.collect{|name| list(name)}
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