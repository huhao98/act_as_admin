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

    def page action, opts={}, &block
      page = @pages[action] 

      if page.nil?
        page = ::ActAsAdmin::Builder::PageConfig.new(opts)
      else
        page = ::ActAsAdmin::Builder::PageConfig.clone(page, opts)
      end

      page.instance_eval(&block) if block_given?
      @pages[action] = page
    end

  end
end
