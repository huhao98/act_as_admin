# encoding: utf-8

module AdminQueryHelper

  def orders_group
    orders = query_result.query.orders
    return unless orders.present?
    bootstrap_btn_group(orders) do |field, opts|
      concat order_link(field, opts){|text, url, active| link_to(text, url, active_btn_option(active))}
    end
  end

  def order_link field, opts={}
    default_dir = opts[:dir].to_s
    applied_dir = applied_dir(field)
    name = field_name(field)
    url = order_url(field, applied_dir, default_dir)
    icon = {
      "desc" => "<i class='icon-sort-up gray'></i>",
      "asc" => "<i class='icon-sort-down gray'></i>",
      "none" => "<i class='icon-sort gray'></i>"
    }[applied_dir || "none"]

    yield("#{name} #{icon}".html_safe, url, applied_dir.present?)
  end

  def order_header field
    orders = query_result.query.orders || {}
    if orders.has_key?(field.to_sym)
      order_link(field, orders[field]){|text, url, active| link_to(text, url)}      
    else
      field_name(field)
    end
  end


  def filter_group *types
    query_meta_data = query_result.query_meta_data
    types = [:select, :scope, :date_range, :search] if types.empty?
    filters = query_result.query.filters.select do |field, opts|
      type = opts[:type] || :search
      types.include? type
    end

    filters.each do |field, opts|
      type = opts[:type]
      case type
      when :date_range
        concat(range_box field, applied_filter(field))

      when :select, :scope
        values = opts[:values] || (query_meta_data[field]||{})[:values] || []
        value = applied_filter(field)

        concat(values_dropdown field, value, values) if type == :select
        concat(scope_buttons field, value, values) if type == :scope
      else
        concat(search_box field, applied_filter(field))
      end
    end
    return nil
  end



  def values_dropdown field, value, values
    hv = field_value_human(field, value) unless value.nil?
    bootstrap_dropdown_button([field_name(field), hv].compact.join(" : ")) do
      concat(content_tag :li, link_to(t("act_as_admin.actions.all"), filter_url(field))) unless value.blank?
      values.each{|v|
        html_opts = {:class=>"active"} if (v.to_s == value.to_s)
        concat content_tag(:li, link_to(field_value_human(field, v), filter_url(field, v)), html_opts)
      }
    end
  end

  def scope_buttons field, value, values
    bootstrap_btn_group(values) do |v|
      active =  (v == value)
      url = active ? filter_url(field) : filter_url(field, v)
      concat link_to(field_value_human(field, v), url, active_btn_option(active))
    end
  end

  def search_box field, value
    params = filter_params field
    form_tag(query_url, :method => :get, :class=>"form-inline"){
      concat query_hidden_fields(:o, params)
      concat query_hidden_fields(:f, params)
      concat text_field_tag("f[#{field}]", value, :placeholder=>field_name(field), :class=>"input-medium " )
      concat submit_tag(t("act_as_admin.actions.search"), :class=>"btn")
      concat link_to(t("act_as_admin.actions.clear"), filter_url(field), :class=>"btn") unless value.blank?
    }
  end

  def range_box field, value
    #value=[1] or value=[1,2] or value=nil
    params = filter_params field    
    value ||= []
    field_options = {:placeholder=>field_name(field), :class=>"input-small datepicker", :readonly=>true, :"data-format"=>"yyyy/mm/dd"}

    form_tag(query_url, :method=>:get, :class=>"form-inline",:style=>"margin-left:10px"){
      concat query_hidden_fields(:o, params)
      concat query_hidden_fields(:f, params)
      concat text_field_tag("f[#{field}][]", value[0], field_options)
      concat content_tag(:span,"-")
      concat text_field_tag("f[#{field}][]", value[1], field_options)
      concat submit_tag(t("act_as_admin.actions.range"), :class=>"btn")
      concat link_to(t("act_as_admin.actions.clear"), filter_url(field), :class=>"btn") unless value.blank?
    }
  end

  private
  def active_btn_option active
    cls = "active btn-info" if active
    {:class => (["btn"] + [cls]).compact.join(" ")}
  end

  def order_url field, applied_dir, default_dir
    dir = applied_dir || default_dir || "asc"
    return query_url query_params.merge(:o=> {field => dir})
  end

  def filter_url field, value=nil
    return query_url filter_params(field, value)
  end

  def query_result
    return @query_result
  end

  def query_params
    @query_result.query_params.merge(params.except(:f, :o))
  end

  def query_url params={}
    return self.instance_exec(params, &@context.query.path_proc)
  end

  def query_hidden_fields prefix, params
    (params[prefix]||{}).collect do |field, value|
      if (value.respond_to? :map)
        value.collect{|v| hidden_field_tag("#{prefix}[#{field}][]", v)}
      else
        hidden_field_tag("#{prefix}[#{field}]", value)
      end
    end.flatten.join("\n").html_safe
  end



  def filter_params field, value=nil
    p = query_params
    p[:f] = (p[:f] || {}).clone
    if (value.nil?)
      p[:f].except!(field)
    else
      p[:f].merge!(field =>value)
    end
    return p
  end

  def applied_dir field
    o = query_params[:o] || {}
    {"desc"=>"asc", "asc"=>"desc"}[o[field]] if (o.keys.include? field)
  end

  def applied_filter field
    return (query_params[:f] || {})[field]
  end

end
