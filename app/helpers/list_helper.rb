module ListHelper

  def data_panel list, item, opts={}
    formatters = list.formatters
    contents = formatters.each.collect do |formatter|
      content_tag(:li) do
        concat(content_tag(:span, field_name(formatter.field), :class=>:head))
        concat(content_tag(:span, formatter.value_of(item, self)))  
      end
    end
    cls = ["list-data", opts[:class]].compact.join(" ")
    content_tag(:ul, contents.join("\n").html_safe, :class => cls) 
  end

  def data_grid list, items, opts={}

    # determine order fields 
    query_params = opts[:query_params]
    order_fields = query_params.orders.keys if query_params
    order_fields ||= []

    # append action formatter to field formatters
    formatters = list.formatters
    if (list.actions.present?)
      as = Proc.new do |item|
        action_group(list.actions, :data_item=>item, :class=>"btn btn-small")
      end
      formatters += [ActAsAdmin::Components::Formatter.new(:actions, :as=> as)]
    end
   
    headers = row(formatters, :cell=>:th) do |formatter|
      field = formatter.field
      order_fields.include?(field) ? render_order(query_params, field) : field_name(field, :model=>list.model)
    end

    body = row(formatters, :cell=>:td, :items=>items) do |formatter, item|
      formatter.value_of(item, self)
    end

    content_tag(:table, :class=>"table table-striped table-data") do
      concat(content_tag(:thead, headers))
      concat(content_tag(:tbody, body))
    end
  end


  private 

  def row formatters, opts={}, &block
    cell_tag = opts.delete(:cell)
    items = opts.delete(:items)
    unless items
      tr(cell_tag, formatters, nil, &block)
    else
      items.collect{|item| tr(cell_tag, formatters, item, &block)}.join("\n").html_safe
    end
  end

  def tr cell_tag, formatters, item=nil, &block
    content_tag(:tr) do
      contents = formatters.collect{|formatter| block.call(formatter, item)}
      contents.each{|content| concat( content_tag(cell_tag, content))}
    end
  end


end
