# encoding: utf-8

require 'act_as_admin/config'
require 'act_as_admin/controller/base'
require 'act_as_admin/controller/query'
require 'act_as_admin/controller/resource_filters'
require 'act_as_admin/helpers/path_helper'

module ActAsAdmin
  module Controller

    extend ActiveSupport::Concern

    module ClassMethods
      attr_reader :admin_config

      def register_model model_class, opts={}, &block
        include ::ActAsAdmin::Helpers::PathHelper
        include ::ActAsAdmin::Controller::Base
        include ::ActAsAdmin::Controller::Query

        pattern = "admin/:action{.:locale,}{.:formats,}{.:handlers,}"
        append_view_path ::ActionView::FileSystemResolver.new("app/views", pattern)
        append_view_path ::ActionView::FileSystemResolver.new(File.expand_path("../../../app/views", __FILE__), pattern)

        @admin_config = ActAsAdmin::Config.new opts
        config_defaults(@admin_config, model_class)
        @admin_config.instance_exec(&block) if block_given?

        #add_breadcrumb model_class.model_name.human, :resources_path
        define_filters @admin_config, model_class
      end

      private

      def config_defaults admin_config, model_class
        title_field = admin_config.opts[:title_field] || :to_s
        resource_name = ->{@resource.send title_field}

        admin_config.instance_eval do
          page :action=>:default do |p|
            p.header(:major, :text=>model_class.model_name.human)
            p.breadcrumb(model_class.model_name.human){resources_path}
          end

          index_page do |p|
            p.action(:new){new_resource_path}
            p.data_action(:edit){|resource| edit_resource_path(resource)}
            p.data_action(:delete, :method=>"delete", :data=>{:confirm =>"你确定要删除吗?"}){|resource| resource_path(resource)}
            query do |q|
              q.query_path {|params| resources_path(params)}
              q.page 10
            end
          end

          show_page do |p|
            p.breadcrumb(resource_name){resource_path(@resource)}

            p.action(:edit){edit_resource_path(@resource)}
            p.action(:delete, :method=>"delete", :data=>{:confirm =>"你确定要删除吗?"}){resource_path(@resource)}
          end

          new_page do |p|
            p.breadcrumb("New")

            p.action(:cancel){resources_path}
            form do |f|
              f.action(:new, :method=>:post){resources_path}
            end
          end

          edit_page do |p|
            p.breadcrumb(resource_name){resource_path(@resource)}
            p.breadcrumb("Edit")

            p.action(:cancel){resource_path(@resource)}
            form do |f|
              f.action(:edit, :method=>:put){|resource| resource_path resource}
            end
          end

        end
      end


      def define_filters admin_config, model_class
        # initialize data for view
        before_filter :initialize_data
        define_method :initialize_data do
          action = params[:action].to_sym
         
          @model = model_class
          @page = admin_config.pages[action] || admin_config.default_page
          @query = admin_config.queries[action]
          @form = admin_config.forms[action]
        end        
        include ::ActAsAdmin::Controller::ResourceFilters
      end

     

    end

  end
end
