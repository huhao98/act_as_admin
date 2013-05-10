module ToolbarHelper

  def toolbar query_result
    query_params = query_result_helper(query_result)
    content_tag(:div, :class=>"toolbar") do
      concat content_tag(:div, :class=>"pull-left"){filter_group(query_params, :select, :scope)}
      concat content_tag(:div, :class=>"pull-right"){filter_group(query_params, :date_range, :search)}
    end
  end

end
