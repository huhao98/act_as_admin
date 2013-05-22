require 'act_as_admin/builder/dsl'
require 'act_as_admin/builder/page_config'
require 'act_as_admin/builder/query_config'
require 'act_as_admin/builder/list_config'
require 'act_as_admin/builder/form_config'
require 'act_as_admin/builder/resource_config'

module ActAsAdmin
  class Config

    attr_reader :pages, :resource_config, :opts
    delegate :header, :to=>:default_page
    
    def initialize opts={}
      @opts = opts
      @resource_config = ActAsAdmin::Builder::ResourceConfig.new(resource_name)
      @pages = {:default => ::ActAsAdmin::Builder::PageConfig.new}
    end

    def model
      @opts[:model]
    end

    def resource_name
      @opts[:resource_name]
    end

    def default_page
      @pages[:default]
    end

    def resource name=nil, &block
      @resource_config.instance_eval(&block) if block_given?
    end

    def page action=nil, opts={}, &block
      if (action.nil?)
        page = @pages[:default]
      else
        page = @pages[action] ||= ::ActAsAdmin::Builder::PageConfig.new
      end

      excluded_actions = (opts.delete :exclude_actions) || []
      page.actions.reject!{|k,v| excluded_actions.include? k}
      
      page.instance_eval(&block) if block_given?
    end

  end
end
