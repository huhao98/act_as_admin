module Admin::Builder
  module Dsl

    extend ActiveSupport::Concern

    def initialize parent=nil
      @parent = parent
    end

    module ClassMethods

      def field name, opts={}
        singular_name = (name.to_s).singularize.to_sym
        inherit = opts.delete :inherit || false
        without_writer = opts.delete(:without_writer) || false
        
        key = opts.delete :key || false
        if (key)
          option_filed name, singular_name, inherit, without_writer, opts
        else
          value_field name, singular_name, inherit, without_writer
        end
      end

      def value_field name, singular_name, inherit, without_writer

        define_method name do
          values = (self.instance_variable_get("@#{name}") ||[])
          if inherit
            parent_value = @parent.send(name) if @parent
            (parent_value || []) + values
          else
            values
          end
        end

        define_method singular_name do |value|
          values = self.instance_variable_get("@#{name}")
          if values.nil?
            values = []
            self.instance_variable_set("@#{name}", values)
          end
          values << value
        end unless without_writer
      end

      def option_filed name, singular_name, inherit, without_writer, opts={}
        proc = opts.delete :proc

        define_method name do
          values = (self.instance_variable_get("@#{name}") || {})
          if inherit
            parent_value = @parent.send(name) if @parent
            (parent_value || {}).merge(values)
          else
            values
          end
        end

        define_method singular_name do |*args, &block|
          key = args[0]
          opts = args[1] || {}

          values = self.instance_variable_get("@#{name}")
          if values.nil?
            values = {}
            self.instance_variable_set("@#{name}", values)
          end

          values[key] = (opts || {})
          values[key][proc] = block unless block.nil?
        end unless without_writer
      end

    end

  end
end
