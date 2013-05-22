require 'act_as_admin/builder/resource_path'

module ActAsAdmin::Builder

  class ResourceConfig
    attr_reader :name, :formatters, :assigners, :inputs, :scopes, :paths

    class FieldConfig
      attr_accessor :field, :resource
      def initialize field, resource
        @field = field
        @resource = resource
      end

      def assign &assign_proc
        raise "Need to supply a block to assign a field" if assign_proc.nil?

        resource.assigners[field.to_sym] = assign_proc
        return self
      end

      def show opts={}, &as
        opts = opts.merge(:as=>as) if block_given?

        f = field.to_sym
        resource.formatters[f] ||= []
        resource.formatters[f]  << ::ActAsAdmin::Components::Formatter.new(f, opts)
        return self
      end

      def input opts={}
        resource.inputs[field.to_sym] = opts
        return self
      end
    end

    def initialize name
      @name = name
      @paths=[]
      [:formatters, :assigners, :inputs, :scopes].each do |attr|
        self.instance_variable_set("@#{attr}".to_sym, Hash.new)
      end
    end

    # Start a field config by chaining following methods
    # - show
    # - input
    # - assign
    # [field] Field name
    # [&block] optional block to create nested fields
    def field field, &block
      if (block_given?)
        resource = nest_resource field, &block
        [:formatters, :assigners, :inputs].each do |t|
          c = resource.send(t)
          self.send(t).merge!(c.inject(Hash.new){|m,v| m.merge!("#{field}.#{v[0]}".to_sym => v[1])})
        end
      end
      return FieldConfig.new(field, self)
    end

    # Config a scoped resource
    # [name] The scoped resource name 
    # [&block] A block that will be evaluated in the context of a scoped resource
    def scope name, &block
      scopes[name] = nest_resource(name, &block)
    end

    def path resource, opts={}
      @paths << ResourcePath.new(resource, opts)
      return @paths.last
    end

    def path_for params
      @paths.select{|path| path.match? params}.first
    end

    def resource_components params
      path = path_for(params)
      path.resource_components(params)
    end


    # All the scope names
    def scope_names 
      scopes.keys
    end

     # Assign evaluated values to the data fields
    # [data] The object which values will be assigned to
    # [opts] 
    # - :use:: The proc evaluation context
    def assign_fields data, opts={}
      context = opts[:use] || self
      assigners.each do |field, field_assigner|
        if field_assigner.is_a? Proc
          value = context.instance_exec(&field_assigner) 
          data.send("#{field}=".to_sym, value)
        end
      end
    end

 
    def find_formatters condition = {}
      scope = condition.delete(:scope)
      fields = condition.delete(:fields)

      scope ||= :default
      if scope == :default
        field_formatters = formatters
      else
        field_formatters = scopes[scope].formatters
      end

      fields ||= field_formatters.keys
      formatters = field_formatters.select{|k,v| fields.include? k }.collect do |field, formatters|
        formatter = formatters.sort{|a, b| a.score(condition) <=> b.score(condition)}.last
        formatter.score(condition) == 0 ? nil : formatter
      end
      return formatters.compact
    end

    def find_inputs fields
      fields ||= inputs.keys
      fields.inject(Hash.new) do |memo, field|
        item = {field => inputs[field]} if inputs.keys.include? field
        memo.merge!(item) 
      end
    end
   
    private
    def nest_resource name, &block
      resource = ActAsAdmin::Builder::ResourceConfig.new(name)
      resource.instance_exec(&block)
      return resource
    end

  end
end
