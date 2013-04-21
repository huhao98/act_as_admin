#encoding: utf-8
module AdminHelper
  include ActAsAdmin::Helpers::PathHelper  
  include ActAsAdmin::Helpers::NavHelper

  def page_header headers
    major = headers[:major]
    minor = headers[:minor]

    content_tag(:h2) do
      concat(resolve_proc_option_in_view(major[:text])) if major
      if minor
        concat(" ")
        concat(content_tag :small, resolve_proc_option_in_view(minor[:text]))
      end
    end
  end


  def field_name field
    @model.human_attribute_name(field)
  end

  def field_value data, field, field_options
    if field_options[:content] 
      return self.instance_exec(data, &field_options[:content])
    else
      return data.send(field.to_sym)
    end
  end  

  def action_name key
    model_name = model_name(@model)
    I18n.translate("helpers.links.#{model_name}.#{key}", :default=>t("helpers.links.#{key}", :default=>key.to_s))
  end

  def action_icon key
    model_name = model_name(@model)
    t("helpers.links.#{model_name}.#{key}_icon", :default=>t("helpers.links.#{key}_icon", :default=>""))
  end

  def action_dropdown actions, opts={}
    return unless actions.present?

    links = actions.collect do |k, v|
      options = v.merge(opts)
      
      link = {}
      link[:name] = action_name(k)
      link[:icon_class] = action_icon(k)

      link[:url] = resolve_proc_option_in_view(options.delete(:url), options.delete(:data_item)) || "#"
      link[:options] = options
      link
    end
    
    link = links.shift
    main_btn = action_link(link)
    return main_btn unless links.size > 0

    content_tag(:div, :class=>"btn-group") do
      concat main_btn
      concat content_tag(:button, content_tag(:span, "", :class=>"caret"), :class=>"btn dropdown-toggle", :"data-toggle"=>"dropdown")
      concat(content_tag(:ul, :class=>"dropdown-menu"){
        links.each do |link|
          link[:options].delete(:class)
          concat content_tag(:li, action_link(link))
        end
      })
    end
  end

  def action_link link
    content = []
    content << content_tag(:i,"", :class=>link[:icon_class]) if link[:icon_class].present?
    content << link[:name]
    link_to(content.join(" ").html_safe, link[:url], link[:options])
  end

  def order_button order
    field = order[0]
    default_dir = order[1][:dir].to_s
    applied_orders = @applied_orders || {}
    applied_dir = {"desc"=>"asc", "asc"=>"desc"}[applied_orders[field]] if (applied_orders.keys.include? field)

    url = order_url(field, applied_dir, default_dir)
    icon = {
      "desc" => "<i class='icon-sort-up gray'></i>",
      "asc" => "<i class='icon-sort-down gray'></i>",
      "none" => "<i class='icon-sort gray'></i>"
    }[applied_dir || "none"]

    cls = "btn"
    cls +=" active" if applied_dir.present?

    link_to("#{@model.human_attribute_name(field)} #{icon}".html_safe, url, :class=>cls)
  end

  def scope_button scope
    url = scope_url scope[0]
    cls = "btn"
    cls +=" active" if @applied_scope && @applied_scope.to_sym == scope[0].to_sym
    link_to(human_attribute_value(@model, :scope, scope[0].to_s), url, :class=>cls )
  end

  def search_box
    content_tag(:div, :class=>"input-append"){
      concat text_field_tag(:search, "", :class=>"span2" )
      concat content_tag(:button, "搜索", :class=>'btn search-btn')
    }
  end

  def query_params
    params.select{|k,v| [:s, :o, :q].include? k.to_sym}.symbolize_keys
  end

  def scope_url scope
    p = query_params
    p[:s] = scope
    return self.instance_exec(p, &@query.path_proc)
  end

  def order_url field, applied_dir, default_dir
    dir = applied_dir || default_dir || "asc"
    p = query_params
    p[:o] = {field => dir}
    return self.instance_exec(p, &@query.path_proc)
  end

  private 
  def resolve_proc_option_in_view proc_or_string, *args
    value = proc_or_string
    if value.is_a? Proc
      return self.instance_exec(args, &value) 
    else
      return value
    end
  end

end