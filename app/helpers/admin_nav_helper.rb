module AdminNavHelper

  def navbar opts={}
    items = ActAsAdmin::Components::Nav.render do |r|
      r.item do |key, cfg, active_opts|
        nav_on(key, cfg) do |url, active|
          html_opts = {:class=>:active} if active
          active_opts[:active] = active
          content_tag :li, link_to(nav_title(key), url), html_opts
        end
      end

      r.group do |key, cfg, contents, active|
        cls = :active if active
        bootstrap_dropdown_menu(nav_title(key), cls){concat(contents.join("\n").html_safe)}
      end

      r.verify_role{|roles| has_role(roles)}
    end
    bootstrap_navbar(opts){items.join("\n").html_safe}
  end
  

  def sidebar_nav cfg={}
    items = ActAsAdmin::Components::Nav.render do |r|
      r.item do |key, cfg, active_opts|
        nav_on(key, cfg) do |url, active|
          active_opts[:active] = active
          sidebar_item(active) do 
            concat(link_to(url){
              concat content_tag(:i, "", :class=>cfg[:icon]) if cfg[:icon]
              concat content_tag(:span, nav_title(key))
            })
          end
        end
      end

      r.group do |key, cfg, contents, active|
        group_id = "#{key}_group"
        collapse = active ? "in" : "out" 
        sidebar_item(active) do
          concat(link_to("javascript:void(0)", :"data-toggle"=>"collapse", :"data-target"=>"##{group_id}"){
            concat content_tag(:i, "", :class=>cfg[:icon]) if cfg[:icon]
            concat content_tag(:span, nav_title(key))
            concat content_tag(:label, contents.size, :class=>"pull-right label")
          })
          concat(content_tag(:div, :id=>group_id, :class=>"subnav collapse #{collapse}"){
            content_tag :ul, contents.join("\n").html_safe
          })
        end
      end

      r.verify_role{|roles| has_role(roles)}
    end

    content_tag(:div, :id=>"sidebar-nav") do
      content_tag(:ul, items.join("\n").html_safe, :id=>"dashboard-menu") 
    end
  end

  def sidebar_item active
    html_opts = {}
    if (active)
      html_opts = {:class=>:active}
      pointer = <<-HTML
        <div class="pointer">
          <div class="arrow"></div>
          <div class="arrow_border"></div>
        </div>
      HTML
    end
    content_tag(:li, html_opts) do
      concat pointer.html_safe if pointer
      yield()
    end
  end


  private

  def has_role roles
    if current_user && current_user.respond_to?(:roles)
      return (current_user.roles & roles).present?
    else
      return true
    end
  end

  def nav_title key
    key.to_s.singularize.classify.constantize.model_name.human rescue key.to_s.capitalize
  end

  def nav_on resource, cfg={}
    opts = {:controller=>resource}.merge(cfg)

    url = opts[:url]
    url = instance_exec(&url) if url.is_a?(Proc)
    url ||= url_for(opts.slice(:controller, :action, :id))

    args = {
      :controller=>current_resource,
      :action=>opts[:action] && params[:action],
      :id=>opts[:id] && params[:id]
    }.reject{|k,v| v.nil?}

    yield(url,(url == url_for(args))) if block_given?
  end

  def current_resource
    resource = params[:controller]
    resource = @context.root_resource_name if (@context)
    return resource
  end
end
