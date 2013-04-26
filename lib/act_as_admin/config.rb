require 'act_as_admin/builder/dsl'
require 'act_as_admin/builder/page'
require 'act_as_admin/builder/form'
require 'act_as_admin/builder/query'
require 'act_as_admin/builder/resource'

module ActAsAdmin
  class Config

    attr_reader :pages, :forms, :queries, :resource, :opts
    
    delegate :header, :data_column, :to=>:default_page
    delegate :query_on, :query_path, :filter, :order, :to=>:default_query
    delegate :query_from, :parent, :field, :to=>:resource

    def initialize opts={}
      @opts = opts
      @resource = ActAsAdmin::Builder::Resource.new
      default_form = ::ActAsAdmin::Builder::Form.new
      @pages = {:default => ::ActAsAdmin::Builder::Page.new}
      @forms = {:new =>default_form, :create=>default_form, :edit=>default_form, :update=>default_form}
      @queries = {:index => ::ActAsAdmin::Builder::Query.new}
    end

    def model
      opts[:model]
    end

    def resource_name
      opts[:resource_name]
    end

    def default_page
      @pages[:default]
    end

    def default_query
      @queries[:index]
    end

    def default_form
      @forms[:new]
    end

    def page action=nil, opts={}, &block
      @page_action = action || :default
      page = @pages[@page_action] ||= ::ActAsAdmin::Builder::Page.new(default_page)

      #exclude actions and data_actions from default
      page.actions.except!(*(opts.delete(:exclude_actions) || []))
      page.data_actions.except!(*(opts.delete(:exclude_data_actions) || []))

      yield(page) if block_given?
      @page_action = nil
    end

    def form action=nil, opts={}
      action = action || @page_action || :new
      @forms[action] ||= ::ActAsAdmin::Builder::Form.new
      yield(@forms[action]) if block_given?
    end

    def query action=nil, opts={}
      action = action || @page_action || :index
      @queries[action] ||= ::ActAsAdmin::Builder::Query.new
      yield(@queries[action]) if block_given?
    end

    def index_page opts={}, &block
      page :index, opts, &block
    end

    def show_page opts={}, &block
      page :show, opts, &block
    end

    def new_page opts={}, &block
      page :new, opts, &block
    end

    def edit_page opts={}, &block
      page :edit, opts, &block
    end

  end
end
