module AdminHelper
  include ActAsAdmin::Helpers::PathHelper  

  def field_name field, opts={}
    context_model = @context.model if @context
    model = opts[:model] || context_model

    return model.human_attribute_name(field) unless model.nil?
    return t(:"attributes.#{field}", :default=>field.to_s.humanize)
  end

  def field_value data, field, opts={}
    return self.instance_exec(data, &opts[:content]) if opts[:content].is_a? Proc
    return data.send(field.to_sym)
  end

  def field_value_human field, value, opts={}
    return if value.nil?
    context_model = @context.model if @context
    model = opts[:model] || context_model

    defaults=[value]
    key = :"values.#{field}.#{value}"
    if (model)
      defaults.unshift(key)
      key = :"#{model.i18n_scope}.values.#{model.model_name.i18n_key}.#{field}.#{value}"
    end
    
    t(key, :default=>defaults)
  end

  def resolve value, *args
    return self.instance_exec(*args, &value) if value.is_a? Proc
    return value
  end

end