module DataGridHelper
  def data_grid page, items, opts={}
    data_columns = page.data_columns.reject{|field, cfg| cfg[:not_on_list]}
    data_actions = page.data_actions

    content_tag(:table, :class=>"table table-striped table-data") do
      concat(content_tag(:thead){ data_grid_header(data_columns, header_renderer(opts)) })
      concat(content_tag(:tbody){ data_grid_body(data_columns, data_actions, items, item_renderer(opts)) })
    end
  end

  private
  def header_renderer opts
    query_params = opts[:query_params]
    if query_params
      fields = query_params.orders.keys
      return Proc.new(){|field| fields.include?(field) ? render_order(query_params, field) : field_name(field)}
    else
      return Proc.new(){|field| field_name(field)}
    end
  end

  def item_renderer opts
    return Proc.new(){|data, field, cfg| field_value(data, field, cfg)}
  end

  def data_grid_header data_columns, renderer
    concat(content_tag(:tr){
      data_columns.each{|field, cfg| concat content_tag(:th, renderer.call(field))}
      concat content_tag(:th, "", :class=>"actions")
    })
  end

  def data_grid_body data_columns, data_actions, items, renderer
    items.each do |data_item|
      concat(content_tag(:tr) {
        data_columns.each{|field, cfg| concat(content_tag(:td, renderer.call(data_item, field, cfg))) }
        actions = action_group(data_actions, :class=>"btn btn-small", :data_item=>data_item)
        concat content_tag(:td, actions, :class=>"item-actions")
      })
    end
  end

end
