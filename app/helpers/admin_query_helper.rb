# encoding: utf-8

module AdminQueryHelper

  # Render a button group for all orders
  def orders_group orders
    orders ||= {}
    bootstrap_btn_group(orders) do |field, opts|
      concat order_link(field, opts){|text, url, active| link_to(text, url, active_btn_option(active))}
    end
  end

  # Render a group of filters for the given filter type
  def filter_group types, opts
    filters = opts.delete(:filters) || {}
    types = [:select, :scope, :date_range, :search] if types.empty?
    filters.each do |field, config|
      if types.include? (config[:type] || :search)
        values = meta_data(field)[:values]
        config = config.merge(:values=> values) if values
        concat render_filter(field, config) 
      end
    end
  end

  def order_header field, opts={}
    unless opts.nil?
      order_link(field, opts){|text, url, active| link_to(text, url)}
    else
      field_name(field)
    end
  end

  def render_filter field, opts={}
    value = filter_value(query_params, field)
    values = opts[:values] || []

    case opts[:type]
    when :date_range
      range_box(field, value)

    when :select
      values_dropdown(field, value, values)

    when :scope
      scope_buttons(field, value, values)

    else
      search_box(field, value)
    end
  end


  private

   # Render a dropdown button as filter select
  def values_dropdown field, value, values
    label = [field_name(field), field_value_human(field, value)].compact.join(" : ")
    bootstrap_dropdown_button(label) do
      concat(content_tag :li, link_to(t("act_as_admin.actions.all"), filter(field).query_url)) unless value.blank?
      values.each do |v|
        html_opts = {:class=>"active"} if (v.to_s == value.to_s)
        url = filter(field,v).query_url
        label = field_value_human(field, v)
        concat content_tag(:li, link_to(label, url, html_opts))
      end
    end
  end

  # Render a button group as filter scope
  def scope_buttons field, value, values
    bootstrap_btn_group(values) do |v|
      filter_value = v unless v == value
      url = filter(field, filter_value).query_url
      html_opts = active_btn_option(filter_value.nil?)
      concat link_to(field_value_human(field, v), url, html_opts)
    end
  end

  # Render a search box
  def search_box field, value
    form_tag(query_url, :method => :get, :class=>"form-inline"){
      concat filter(field).hidden_fields
      concat text_field_tag("f[#{field}]", value, :placeholder=>field_name(field), :class=>"input-medium " )
      concat submit_tag(t("act_as_admin.actions.search"), :class=>"btn")
      concat link_to(t("act_as_admin.actions.clear"), filter(field).query_url, :class=>"btn") unless value.nil?
    }
  end

  # Render a range box
  def range_box field, value
    #value=[1] or value=[1,2] or value=nil
    value ||= []
    form_tag(query_url, :method=>:get, :class=>"form-inline",:style=>"margin-left:10px"){
      input_options = {
        :placeholder=>field_name(field),
        :class=>"input-small datepicker",
        :readonly=>true,
        :"data-format"=>"yyyy/mm/dd"
      }
      concat hidden_fields(filter(field).query_params)
      concat text_field_tag("f[#{field}][]", value[0], input_options)
      concat content_tag(:span,"-")
      concat text_field_tag("f[#{field}][]", value[1], input_options)
      concat submit_tag(t("act_as_admin.actions.range"), :class=>"btn")
      concat link_to(t("act_as_admin.actions.clear"), filter(field).query_url, :class=>"btn") unless value.blank?
    }
  end


  def meta_data field
    meta_data = @query_result.query_meta_data if @query_result
    meta_data ||= {}
    meta_data[field] || {}
  end

  def active_btn_option active
    cls = "active btn-info" if active
    {:class => (["btn"] + [cls]).compact.join(" ")}
  end

  # Helper method to generate an order link
  def order_link field, opts
    default = opts[:dir].to_s
    value = order_value query_params, field

    icon = {
      "desc" => "<i class='icon-sort-up gray'></i>",
      "asc" => "<i class='icon-sort-down gray'></i>",
      "none" => "<i class='icon-sort gray'></i>"
    }[value || "none"]
    yield("#{field_name(field)} #{icon}".html_safe, order(field, value, default).query_url, value.present?)
  end

end
