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
        include ::ActAsAdmin::Controller::Query
        include ::ActAsAdmin::Controller::BreadCrumb

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
        resource_name = admin_config.resource_name

        admin_config.instance_eval do
          page :index do 
            header(:major, :text=>model_class.model_name.human)
            action(:new){new_resource_path}
            query do
              query_path {|params| resources_path(params)}
              page 10
            end
            
            list do
              action(:edit){|order| edit_resource_path(order)}
              action(:delete, :method=>"delete"){|order| resource_path(order)}
            end
          end

          page :show do 
            header(:major, :text=>model_class.model_name.human)
            header(:minor){@context.resource_title}

            action(:edit){edit_resource_path(@resource)}
            action(:delete, :method=>"delete", :data=>{:confirm =>"你确定要删除吗?"}){resource_path(@resource)}

            list
          end

          page :new do 
            header(:major, :text=>"New #{model_class.model_name.human}")
            breadcrumb {add_breadcrumb "New #{model_class.model_name.human}"}

            form(:as=>resource_name) do
              submit(:create, :method=>:post){resources_path}
              cancel(:cancel){redirect_to_resources_path}
            end
          end

          page :edit do 
            header(:major, :text=>"Edit #{model_class.model_name.human}")
            breadcrumb {add_breadcrumb "Edit #{model_class.model_name.human}"}

            form(:as=>resource_name) do
              submit(:update, :method=>:put){|resource| resource_path(resource)}
              cancel(:cancel){|resource| resource_path(resource)}
            end
          end


        end
      end

    end

  end
end
