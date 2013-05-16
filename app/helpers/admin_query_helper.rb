# encoding: utf-8
module AdminQueryHelper

  # Create QueryParams from query result
  def query_result_helper query_result=nil
    filters = query_result.filters.inject({}) do |memo, v|
      field = v[0]
      memo.merge!(field => v[1].merge(query_result.query_meta_data[field] || {}))
    end
    orders = query_result.orders
    query_params = query_result.query_params.merge(params.except(:f, :o))

    view_helper = self
    return ActAsAdmin::Helpers::QueryParams.new(query_params, filters, orders) do |param|
      view_helper.instance_exec(param, &query_result.path_proc)
    end
  end

  # Create QueryParams from filters and orders
  def query_params_helper filters, orders
    query_params = params.clone
    return ActAsAdmin::Helpers::QueryParams.new(query_params) do |params|
      url_for(params)
    end
  end


 # Render a button group for all orders
  def orders_group query_params
    bootstrap_btn_group(query_params.orders) do |field, opts|
      concat order_link(query_params, field){|text, url, active| link_to(text, url, active_btn_option(active))}
    end
  end

  # Render a group of filters for the given filter type
  def filter_group query_params, *types
    types = [:select, :scope, :date_range, :search] if types.empty?
    query_params.filters.each do |field, config|
      type = config[:type]
      concat render_filter(query_params, field, type) if types.include?(type || :search)
    end
  end

  def render_order query_params, field
    order_link(query_params, field){|text, url, active| link_to(text, url)}
  end

  def render_filter query_params, field, type
    case type
    when :date_range
      range_box(query_params, field)

    when :select
      values_dropdown(query_params, field)

    when :scope
      scope_buttons(query_params, field)

    else
      search_box(query_params, field)
    end
  end

  # Render a dropdown button as filter select
  def values_dropdown query_params, field
    filter_opts = query_params.filters[field] || {}
    value = query_params.filter_value(field)
    values = filter_opts[:values] || []

    label = [field_name(field), field_value_human(field, value)].compact.join(" : ")
    bootstrap_dropdown_button(label) do
      concat(content_tag :li, link_to(t("act_as_admin.actions.all"), query_params.filter(field).url)) unless value.blank?
      values.each do |v|
        html_opts = {:class=>"active"} if value.eql?(v.to_s)
        url = query_params.filter(field,v).url
        label = field_value_human(field, v)
        concat content_tag(:li, link_to(label, url, html_opts))
      end
    end
  end

  # Render a button group as filter scope
  def scope_buttons query_params, field
    filter_opts = query_params.filters[field] || {}
    value = query_params.filter_value(field)
    values = filter_opts[:values] || []

    bootstrap_btn_group(values) do |v|
      filter_value = v unless value.eql?(v.to_s)

      url = query_params.filter(field, filter_value).url
      html_opts = active_btn_option(filter_value.nil?)
      concat link_to(field_value_human(field, v), url, html_opts)
    end
  end

  # Render a search box
  def search_box query_params, field
    value = query_params.filter_value(field)
    form_tag(query_params.url, :method => :get, :class=>"form-inline"){
      concat hidden_fields(query_params.filter(field).params)
      concat text_field_tag("f[#{field}]", value, :placeholder=>field_name(field), :class=>"input-medium " )
      concat submit_tag(t("act_as_admin.actions.search"), :class=>"btn")
      concat link_to(t("act_as_admin.actions.clear"), query_params.filter(field).url, :class=>"btn") unless value.nil?
    }
  end

  # Render a range box
  def range_box query_params, field
    #value=[1] or value=[1,2] or value=nil
    value = value = query_params.filter_value(field) || []
    form_tag(query_params.url, :method=>:get, :class=>"form-inline",:style=>"margin-left:10px"){
      input_options = {
        :placeholder=>field_name(field),
        :class=>"input-small datepicker",
        :readonly=>true,
        :"data-format"=>"yyyy/mm/dd"
      }
      concat hidden_fields(query_params.filter(field).params)
      concat text_field_tag("f[#{field}][]", value[0], input_options)
      concat content_tag(:span,"-")
      concat text_field_tag("f[#{field}][]", value[1], input_options)
      concat submit_tag(t("act_as_admin.actions.range"), :class=>"btn")
      concat link_to(t("act_as_admin.actions.clear"), query_params.filter(field).url, :class=>"btn") unless value.blank?
    }
  end

  # Helper method to generate an order link
  def order_link query_params, field
    value = query_params.order_value(field)
    order_opts = query_params.orders[field] || {}
    default_dir = order_opts[:dir] || "asc"

    icon = {
      "desc" => "<i class='icon-sort-up gray'></i>",
      "asc" => "<i class='icon-sort-down gray'></i>",
      "none" => "<i class='icon-sort gray'></i>"
    }[value || "none"]
    yield("#{field_name(field)} #{icon}".html_safe, query_params.order(field, value, default_dir.to_s).url, value.present?)
  end

  private 

  def active_btn_option active
    cls = "active btn-info" if active
    {:class => (["btn"] + [cls]).compact.join(" ")}
  end

  def hidden_fields params
    cleaned_hash = params.except("action", "controller", "commit", "utf8").reject { |k, v| v.nil? }
    pairs = cleaned_hash.to_query.split(Rack::Utils::DEFAULT_SEP)
    tags = pairs.map do |pair|
      key, value = pair.split('=', 2).map { |str| Rack::Utils.unescape(str) }
      hidden_field_tag(key, value)
    end
    tags.join("\n").html_safe
  end

end
