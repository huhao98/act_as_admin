module ActAsAdmin::Components
  class Formatter
    attr_reader :field
    
    def initialize field, opts={}
      @opts = opts
      @field = field
    end

    # format as
    # when it is a Proc, it will evaluate the proc with data
    # when it is a symble, such as :date_tiem. The value will be renderred accordingly
    # when it is not set, it will evaluate the field value.
    def as
      @opts[:as]
    end

    def actions
      [@opts[:action]].flatten.compact
    end

    def formats
      [@opts[:format]].flatten.compact
    end

    def score condition={}
      arank = rank condition[:action], actions
      frank = rank condition[:format], formats
      return 0 if [arank, frank].min == 0
      return arank + frank
    end

    def value_of data, context=nil
      context ||= self
      return context.instance_exec(data, &as) if as.is_a? Proc

      case as
      when :date_time
        context.l data.send(field.to_sym), :default=>:long
      else
        field_value(field, data)
      end
    end

    private 

    def rank c, f
      return 2 if ([c] - f).empty?
      return 1 if f.empty?
      return 0.5 if c.nil?
      return 0
    end

    def field_value field, data
      field.to_s.split(".").inject(data) do |data, field|
        data.send(field.to_sym) unless data.nil?
      end
    end

  end
end
