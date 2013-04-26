module AdminHelper
  include ActAsAdmin::Helpers::PathHelper  

  def field_name field
    @context.model.human_attribute_name(field)
  end

  def field_value data, field, opts
    return self.instance_exec(data, &opts[:content]) if opts[:content].is_a? Proc
    return data.send(field.to_sym)
  end

  def field_value_human field, value, model = nil
    scope = model.nil? ? "values" :  model.i18n_scope 
    t(:"#{scope}.#{field}.#{value}", :default=>value)
  end

  def page_header headers
    major = headers[:major]
    minor = headers[:minor]
    content_tag(:h2) do
      concat(resolve(major[:text])) if major
      if minor
        concat(" ")
        concat(content_tag :small, resolve(minor[:text]))
      end
    end
  end

  def action_group actions, opts={}
    data = opts.delete(:data_item)
    content_tag(:div, :class=>"btn-group") do
      actions.each{|k, v| concat action_link(k, v.merge(opts), data)}
    end
  end

  def action_dropdown actions, opts={}
    return unless actions.size > 0
    data = opts.delete(:data_item)
    actions = actions.to_a
    first = actions.slice(0)
    reset = actions.slice(1..actions.size-1)

    main_btn = action_link *[first[0], first[1].merge(opts), data].compact
    return main_btn unless reset.size > 0

    content_tag(:div, :class=>"btn-group") do
      concat main_btn
      concat content_tag(:button, content_tag(:span, "", :class=>"caret"), :class=>"btn dropdown-toggle", :"data-toggle"=>"dropdown")
      concat(content_tag(:ul, :class=>"dropdown-menu"){
        reset.each{|item| concat content_tag(:li, action_link(item[0], item[1].except(:class), data))}
      })
    end
  end

  
  private 

  def action_name key
    I18n.translate("helpers.links.#{@context.resource_name}.#{key}", :default=>t("helpers.links.#{key}", :default=>key.to_s))
  end

  def action_icon key
    t("helpers.links.#{@context.resource_name}.#{key}_icon", :default=>t("helpers.links.#{key}_icon", :default=>""))
  end

  def action_link key, opts, data=nil
    name = action_name(key)
    icon = action_icon(key)
    url = resolve(opts.delete(:url), data) || "#"

    content = [name]
    content.unshift(content_tag :i,"", :class=>icon) unless icon.nil?
    link_to(content.join(" ").html_safe, url, opts)
  end

  def resolve value, *args
    return self.instance_exec(args, &value) if value.is_a? Proc
    return value
  end

end