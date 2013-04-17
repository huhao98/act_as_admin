require 'admin/builder/dsl'
require 'admin/builder/page'
require 'admin/builder/form'
require 'admin/builder/query'

module Admin
  class Config
    include ::Admin::Builder::Dsl

    attr_reader :pages, :forms, :queries, :controller, :opts
    field :parents, :inherit=>false, :key=> true
    delegate :header, :data_column, :to=>:default_page
    delegate :query_on, :query_path, :scope, :order, :to=>:default_query

    def initialize opts={}
      @opts = opts
      default_form = ::Admin::Builder::Form.new
      @pages = {:default => ::Admin::Builder::Page.new}
      @forms = {:new =>default_form, :edit=>default_form}
      @queries = {:index => ::Admin::Builder::Query.new}
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
      page = @pages[@page_action] ||= ::Admin::Builder::Page.new(default_page)

      #exclude actions and data_actions from default
      page.actions.except!(*(opts.delete(:exclude_actions) || []))
      page.data_actions.except!(*(opts.delete(:exclude_data_action) || []))

      yield(page) if block_given?
      @page_action = nil
    end

    def form opts={}
      action = opts.delete(:action) || @page_action || :new
      @forms[action] ||= ::Admin::Builder::Form.new
      yield(@forms[action]) if block_given?
    end

    def query opts={}
      action = opts.delete(:action) || @page_action || :index
      @queries[action] ||= ::Admin::Builder::Query.new
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
