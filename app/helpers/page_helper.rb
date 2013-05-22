# encoding: utf-8
module PageHelper

  # Render page header
  def page_header headers
    return if headers.empty?
    
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


  
end
