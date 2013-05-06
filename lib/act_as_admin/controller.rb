# encoding: utf-8

require 'act_as_admin/config'
require 'act_as_admin/controller/base'
require 'act_as_admin/controller/bread_crumb'
require 'act_as_admin/controller/query'
require 'act_as_admin/controller/context'
require 'act_as_admin/helpers/path_helper'

module ActAsAdmin
  module Controller

    extend ActiveSupport::Concern

    module ClassMethods
      attr_reader :admin_config

      def register_model model_class, opts={}, &block
        include ::ActAsAdmin::Helpers::PathHelper
        include ::ActAsAdmin::Controller::Base
        include ::ActAsAdmin::Controller::BreadCrumb
        include ::ActAsAdmin::Controller::Query

        pattern = "act_as_admin/:action{.:locale,}{.:formats,}{.:handlers,}"
        append_view_path ::ActionView::FileSystemResolver.new("app/views", pattern)
        append_view_path ::ActionView::FileSystemResolver.new(File.expand_path("../../../app/views", __FILE__), pattern)

        resource_name = opts.delete(:as) || to_resource_name(self)
        @admin_config = ActAsAdmin::Config.new opts.merge(:model=>model_class, :resource_name=>resource_name.to_s)
        config_defaults(@admin_config, opts)
        @admin_config.instance_exec(&block) if block_given?
      end

      private

      def to_resource_name(controller_class)
        names = controller_class.name.underscore.split("_")
        names.slice!(-1)
        return names.join("_").singularize
      end

      def config_defaults admin_config, opts={}
        model_class = admin_config.model
        title_field = admin_config.opts[:title_field] || :to_s

        admin_config.instance_eval do
          page :default do |p|
            p.header(:major, :text=>model_class.model_name.human)
            p.header(:minor){@resource.send(title_field) if @resource}            
            p.breadcrumb(:resources){[model_class.model_name.human, resources_path] unless @context.exclude_nested_index?}
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
            p.breadcrumb(:resource){[ @resource.send(title_field), resource_path(@resource)]}

            p.action(:edit){edit_resource_path(@resource)}
            p.action(:delete, :method=>"delete", :data=>{:confirm =>"你确定要删除吗?"}){resource_path(@resource)}
          end

          new_page do |p|
            p.breadcrumb("New #{model_class.model_name.human}")

            p.action(:cancel){resources_path}
            form do |f|
              f.action(:new, :method=>:post){resources_path}
            end
          end

          edit_page do |p|
            p.breadcrumb(:resource){[ @resource.send(title_field), resource_path(@resource)]}
            p.breadcrumb("Edit #{model_class.model_name.human}")

            p.action(:cancel){resource_path(@resource)}
            form do |f|
              f.action(:edit, :method=>:put){|resource| resource_path resource}
            end
          end

        end
      end

    end

  end
end
