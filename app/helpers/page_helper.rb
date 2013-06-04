# encoding: utf-8
module PageHelper

  # render content_header section which includes page header and actions
  def content_header
    return unless @context

    headers = @context.page.headers
    actions = @context.page.actions
    data =  @resource
    content_tag(:div, :class=>"content-header") do
      concat content_tag(:div, page_header(headers), :class=>"pull-left")
      concat content_tag(:div, action_group(actions, :class=>"btn", :data_item=>data), :class=>"pull-right") if actions
    end
  end

  # Render page header
  def page_header headers
    return if headers.empty?
    major = headers[:major]
    minor = headers[:minor]
    content_tag(:h3) do
      concat(resolve(major[:text])) if major
      if minor
        concat(" ")
        concat(content_tag :small, resolve(minor[:text]))
      end
    end
  end

  def toolbar query_result
    query_params = query_result_helper(query_result)
    content_tag(:div, :class=>"toolbar") do
      concat content_tag(:div, :class=>"pull-left"){filter_group(query_params, :select, :scope)}
      concat content_tag(:div, :class=>"pull-right"){filter_group(query_params, :date_range, :search)}
    end
  end

  def paging items
    count = items.total_entries
    name = "Entry"

    content_tag(:div, :class=>"toolbar") do
      desc = t("will_paginate.total", 
        :from=>items.offset+1, 
        :to=>items.offset + items.count, 
        :total=>count, 
        :item=>(count > 1 ? name.pluralize : name)).html_safe
      concat content_tag(:div, desc, :class=>"pull-left")
      concat content_tag(:div, will_paginate(items, :renderer => BootstrapPagination::Rails), :class=>"pull-right")
    end
  end

  def panel opts={}, &block
    content_tag(:div, :class=>"panel") do
      title = opts.delete :title
      concat(content_tag(:div, :class=>"panel-title"){
        concat content_tag(:h5, title)
      }) if title.present?

      content_cls = ["panel-content"]
      content_cls << "nopadding" if opts.delete(:nopadding)
      concat(content_tag(:div, :class=>content_cls.join(" ")){
        yield() if block_given?  
      })
    end
  end

  def status_label data
    {
      -1=> content_tag(:span, "未开始", :class=>"label"),
      0=> content_tag(:span, "进行中", :class=>"label label-success"),
      1=> content_tag(:span, "已结束", :class=>"label label-important")
    }[data <=> DateTime.now]
  end
  
end
