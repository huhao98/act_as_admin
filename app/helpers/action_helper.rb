module ActionHelper
  # Render button group of action links
  def action_group actions, opts={}
    data = opts.delete(:data_item)
    content_tag(:div, :class=>"btn-group") do
      actions.each{|k, v| concat action_link(k, opts.merge(v), data)}
    end
  end

  # Render a dropdown button
  def action_dropdown actions, opts={}
    return unless actions.size > 0
    data = opts.delete(:data_item)
    actions = actions.to_a
    first = actions.slice(0)
    reset = actions.slice(1..actions.size-1)
    main_btn = action_link *[first[0], first[1].merge(opts), data].compact
    return main_btn unless reset.size > 0

    content_tag(:div, :class=>"btn-group") do
      concat main_btn
      concat content_tag(:button, content_tag(:span, "", :class=>"caret"), :class=>"btn dropdown-toggle", :"data-toggle"=>"dropdown")
      concat(content_tag(:ul, :class=>"dropdown-menu"){
               reset.each{|item| concat content_tag(:li, action_link(item[0], item[1].except(:class), data))}
      })
    end
  end


  private
  def action_link key, opts, data=nil
    url = resolve(opts.delete(:url), data)
    return unless url

    name = t("helpers.links.#{@context.resource_name}.#{key}", :default=>t("helpers.links.#{key}", :default=>key.to_s))
    icon = t("helpers.links.#{@context.resource_name}.#{key}_icon", :default=>t("helpers.links.#{key}_icon", :default=>""))
    content = [name]
    content.unshift(content_tag :i,"", :class=>icon) unless icon.nil?
    link_to(content.join(" ").html_safe, url, opts)
  end
end
