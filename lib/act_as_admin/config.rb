require 'act_as_admin/builder/dsl'
require 'act_as_admin/builder/page'
require 'act_as_admin/builder/form'
require 'act_as_admin/builder/query'

module ActAsAdmin
  class Config
    include ::ActAsAdmin::Builder::Dsl

    attr_reader :pages, :forms, :queries, :controller, :opts
    field :parents, :inherit=>false, :key=> true
    delegate :header, :data_column, :to=>:default_page
    delegate :query_on, :query_path, :scope, :order, :to=>:default_query

    def initialize opts={}
      @opts = opts
      default_form = ::ActAsAdmin::Builder::Form.new
      @pages = {:default => ::ActAsAdmin::Builder::Page.new}
      @forms = {:new =>default_form, :edit=>default_form}
      @queries = {:index => ::ActAsAdmin::Builder::Query.new}
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

    def page opts={}
      @page_action = opts.delete(:action) || :default
      page = @pages[@page_action] ||= ::ActAsAdmin::Builder::Page.new(default_page)

      #exclude actions and data_actions from default
      page.actions.except!(*(opts.delete(:exclude_actions) || []))
      page.data_actions.except!(*(opts.delete(:exclude_data_action) || []))

      yield(page) if block_given?
      @page_action = nil
    end

    def form opts={}
      action = opts.delete(:action) || @page_action || :new
      @forms[action] ||= ::ActAsAdmin::Builder::Form.new
      yield(@forms[action]) if block_given?
    end

    def query opts={}
      action = opts.delete(:action) || @page_action || :index
      @queries[action] ||= ::ActAsAdmin::Builder::Query.new
      yield(@queries[action]) if block_given?
    end

    def index_page opts={}, &block
      page :action=>:index, &block
    end

    def show_page opts={}, &block
      page :action=>:show, &block
    end

    def new_page opts={}, &block
      page :action=>:new, &block
    end

    def edit_page opts={}, &block
      page :action=>:edit, &block
    end

  end
end
