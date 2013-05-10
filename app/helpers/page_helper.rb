# encoding: utf-8
module PageHelper

  # Render page header
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

  def paging query_result
  end


  def status_label data
    {
      -1=> content_tag(:span, "未开始", :class=>"label"),
      0=> content_tag(:span, "进行中", :class=>"label label-success"),
      1=> content_tag(:span, "已结束", :class=>"label label-important")
    }[data <=> DateTime.now]
  end


  #<li>
  #  <dt><strong><%= Task.human_attribute_name(:name) %>:</strong></dt>
  #  <dd><%= @task.name%></dd>
  #</li>
  def data_item title, description=nil, opts={}
    content_tag(:div, :class=>"item") do
      buf = content_tag(:dt, content_tag(:strong, title))
      buf += content_tag(:dd, :style=>opts.delete(:style)) do
        if (description.nil?)
          yield() if block_given?
        else
          description
        end
      end
    end
  end
end
