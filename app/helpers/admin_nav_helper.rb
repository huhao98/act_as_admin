module AdminNavHelper

  def navbar opts={}
    bootstrap_navbar(opts) do
      nav_items = opts[:nav_items] || Rails.configuration.nav.nav_items
      nav_items.each do |key, opts|
        if opts[:resources].nil?
          concat(nav_item key, opts)
        else
          concat(nav_group key, opts[:resources])
        end
      end
    end
  end

  private

  def nav_item key, cfg={}
    if cfg[:with_role].present? && current_user && current_user.respond_to?(:roles)
      return if (current_user.roles & cfg[:with_role]).blank?
    end

    nav_on(key, cfg) do |url, active|
      opts = {:class=>:active} if active
      yield(active) if block_given?      
      content_tag :li, link_to(nav_title(key), url), opts
    end
  end

  def nav_title key
    key.to_s.singularize.classify.constantize.model_name.human rescue key.to_s.capitalize
  end

  def nav_group key, resources
    active = false
    nav_items = resources.collect do |resource|
      nav_item(*[resource].flatten.compact){|item_active| active ||= item_active}
    end
    cls = :active if active
    bootstrap_dropdown_menu(key, cls){concat(nav_items.join("\n").html_safe)}
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
    active = (url == url_for(args))

    yield(url,active) if block_given?
  end

  def current_resource
    resource = params[:controller]
    if (@context && @context.parents.present?)
      resource_name = @context.parents.first[1][:resource_name]
      resource = resource_name.to_s.pluralize if resource_name
    end
    return resource
  end
end
