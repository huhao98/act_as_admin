module ActAsAdmin::Builder
  module Dsl
    extend ActiveSupport::Concern

    module ClassMethods

      def field name, opts={}
        singular_name = (name.to_s).singularize.to_sym
        option_filed name, singular_name, opts
      end

      def option_filed name, singular_name, opts={}
        proc = opts.delete :proc

        define_method name do
          (self.instance_variable_get("@#{name}") || {})
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
        end 
      end

    end

  end
end
