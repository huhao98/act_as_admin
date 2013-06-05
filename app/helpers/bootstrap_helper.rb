module BootstrapHelper

  class TabBuilder
    attr_accessor :tabs

    def tab name, opts={}, &block
      @tabs ||= []
      @tabs << {:name=>name, :opts=>opts, :proc=>block}
    end

    def tabs
      return @tabs || []
    end
  end

  def bootstrap_form_fields form, model, &block
    BootstrapFormBuilder.render_items(form, model, self, &block)
  end

  # Render a standard bootstrap sidebar panel with nav-stacked, nav-pills content
  #
  # opts:: Options that will be passed to the yieled block
  def bootstrap_sidebar opts={}
    content_tag(:div, :class=>"section sidebar-nav") do
      nav_class = opts.delete(:nav_class) || "nav-pills nav-stacked"
      content_tag(:ul, :class=>"nav #{nav_class}") do
        header = opts.delete(:header)
        concat(content_tag :li, header.html_safe, :class=>"nav-header") if header.present?
        yield(opts) if block_given?
      end
    end
  end


  # Render a standard fixed-top bootstrap navbar
  # It will yield to a block that will output nav menus as <li> markup.
  # #bootstrap_dropdown_menu will output a menu markup.
  #
  # opts[:brand]:: The html markups for brand section
  # opts[:right]:: The html markups for the pull-right section
  def bootstrap_navbar opts={}, &block
    brand = opts.delete :brand || ""
    right = opts.delete :right || ""

    content_tag(:div, :class=>"navbar navbar-fixed-top") do
      content_tag(:div, :class=>"navbar-inner") do
        content_tag(:div, :class=>"container-fluid") do
          concat(nav_collapse.html_safe)
          concat(link_to brand.html_safe, "#", :class=>"brand")
          nav = content_tag(:div, :class=>"container-fluid nav-collapse") do
            concat(content_tag(:ul, :class=>"nav", &block))
            concat(content_tag(:ul, right, :class=>"nav pull-right"))
          end
          concat(nav)
        end
      end
    end
  end

  # Render a dropdown menu <li> markup in the bootstrap nav bar
  # It will yield to a block that will output the menu items as html <li> tag
  #
  # menu:: The text on the menu
  def bootstrap_dropdown_menu menu, cls=nil
    opts = {:class=>["dropdown",cls].compact.join(" ")}
    content_tag(:li, opts) do
      concat link_to(%{#{menu} #{content_tag :b, "", :class=>"caret"}}.html_safe, "#", :class=>"dropdow-toggle", :"data-toggle"=>"dropdown")
      concat content_tag(:ul, :class=>"dropdown-menu"){yield}
    end
  end

  # Render a bootstrap dropdown button.
  # The yielded block should render each dropdown item as a <li>
  #
  # content:: The html content on the button
  # opts[:class]:: The dropdown button class, default is "btn"
  def bootstrap_dropdown_button content, opts={}
    btn_class = (opts||{}).delete(:class) || "btn"
    content_tag(:div, :class=>"btn-group") do
      concat link_to("#", :class=>"#{btn_class} dropdown-toggle", :"data-toggle"=>"dropdown"){
        concat content
        concat " "
        concat content_tag :span, "", :class=>"caret"
      }
      concat content_tag(:ul, :class=>"dropdown-menu"){yield if block_given?}
    end
  end


  # Render a bootstrap button group
  # data:: The data content in the button group. If it is an emuratable object, this method
  # will yield the block with each item in the collection.
  def bootstrap_btn_group data=nil, &block
    content_tag(:div, :class=>"btn-group") do
      if data.respond_to? :each
        data.each(&block)
      else
        yield data
      end
    end
  end


  # Render standard fav link icons for different devices.
  # It normally embeded in the <header>
  def bootstrap_fav_links
    render "components/bootstrap/fav_links"
  end

  # Render a bootstrap modal panel.
  # It will yield to a block that should ouput the modal-body content
  #
  # options[:id]:: Dialog id
  # options[:title]:: Dialog title, default "Title"
  # options[:actions]:: Html markups for modal-footer section, default is a Cancel button
  # options[:remote_path]:: If presented, the modal div will have 'data-remote-path' attribute set to this value
  def bootstrap_modal options
    id = options.delete(:id)
    remote_path = options.delete(:remote_path)
    title=options.delete(:title) || "Title"
    actions = options.delete(:actions) || [link_to("Cancel","#", :class=>"btn ", :"data-dismiss"=>"modal", :"aria-hidden"=>"true")]
    cls = options.delete(:class) || ""

    modal_options = {:class=>"modal hide fade #{cls}"}
    modal_options[:id] = id if id.present?
    modal_options[:"data-remote-path"] = remote_path if remote_path.present?

    content_tag(:div, modal_options) do
      concat content_tag(:div, :class=>"modal-header"){
               concat content_tag(:button,"&times;".html_safe, :type=>"button", :class=>"close", :"data-dismiss"=>"modal", :"aria-hidden"=>"true")
               concat content_tag(:h3, title)
      }
      concat content_tag(:div, :class=>"modal-body"){yield if block_given?}
      concat content_tag(:div, actions.join("\n").html_safe, :class=>"modal-footer")
    end
  end


  # Render a bootstrap tab pane
  # Example code:
  # <tt>
  #   bootstrap_tabs(tab_pos: "tabs-top") do |t|
  #     t.tab "Tab1", :id=>"id_of_tab1" do
  #       ...
  #     end
  #     t.tab "Tab2", :id=>"id_of_tab2" do
  #       ...
  #     end
  #   end
  # </tt>
  #
  # Parameters for the tab panel
  # opts[:tab_pos]:: The bootstrap class name for the tab position, like "tab-top".
  #                  Default value is "tab-top"
  #
  # Parameters for each tab
  # name:: The tab name
  # opts[:id]:: The tab id, default value is the tab name
  #
  def bootstrap_tab_pane opts={}
    tab_builder = TabBuilder.new
    yield(tab_builder) if block_given?

    tab_pos = opts.delete(:tab_pos) || "tabs-top"
    tab_options = tab_builder.tabs.collect do |item|
      opts = item[:opts] || {}
      name = item[:name]
      id = opts.delete(:id) || name
      {:id=>id, :link=>link_to(name, "##{id}", :"data-toggle"=>"tab"), :content_proc=>item[:proc], :opts=>opts}
    end

    content_tag :div, :class=>"tabbable #{tab_pos}" do
      concat content_tag(:ul, :class=>"nav nav-tabs"){
        tab_options.each_with_index do |item, index|
          cls = "active" if index==0
          concat content_tag(:li, item[:link], :class=>cls)
        end
      }
      concat content_tag(:div, :class=>"tab-content"){
        tab_options.each_with_index do |item, index|
          opts = {:id=>item[:id], :class=>"tab-pane #{'active' if index==0}"}.merge(item[:opts])
          concat content_tag(:div, opts){
            proc = item[:content_proc]
            proc.call if proc
          }
        end
      }
    end
  end

  # Render a bootstrap button
  # Example code:
  # <tt>
  #   bootstrap_link_button("button text")
  # => <a href="#" class="btn">button text</a>
  # 
  #   bootstrap_link_button("button text", "url")
  # => <a href="url" class="btn">button text</a>
  # 
  #   bootstrap_link_button("button text", "url", :class=>"btn-block")
  # => <a href="url" class="btn btn-block">button text</a>
  # 
  #   bootstrap_link_button("button text", "url", :class=>"btn-block", :icon =>'icon-picture')
  # => <a href="url" class="btn btn-block"><i class="icon-picture"></i> button text</a>
  # </tt>
  def bootstrap_link_button *args
    options = args.extract_options!
    text, url = args.slice!(0,2)
    options[:href] = url || '#'
    append_class_for_options(options,"btn")
    icon = options.delete(:icon)
    content_tag(:a, options) do
      concat bootstrap_icon(icon) if icon
      concat " #{text}" if text
    end
  end
  alias :bootstrap_link_btn :bootstrap_link_button

  # Render a bootstrap button
  # Example:
  # <tt>
  #   bootstrap_button "a button", :class => "btn-block"
  # => <button class="btn btn-block">a button</button>
  #
  #   bootstrap_button "a button", :class => "btn-block", :icon => 'icon-picture'
  # => <button class="btn btn-block">
  #      <i class="icon-picture"></i>
  #      a button
  #    </button>
  #
  #   bootstrap_button "Button", :type => :button
  # => <input class="btn" type="button" value="Button" />
  #
  #   bootstrap_button "Submit", :type => :submit, :class => "btn-primary"
  # => <input class="btn btn-primary" type="submit" value="Submit" />
  #
  # </tt>
  def bootstrap_button *args
    options = args.extract_options!
    text, url = args.slice!(0,2)
    return bootstrap_link_button text, url, options if url

    icon = options.delete(:icon)
    input_type = options.delete(:type)
    input_type = ['button', 'submit'].select{|t| t == input_type.to_s }.first
    tag = input_type ? :input : :button
    append_class_for_options(options,"btn")
    case tag
    when :button
      content_tag(tag, options){ 
        concat(bootstrap_icon(icon)) if icon 
        concat text
      }
    when :input
      tag(tag, options.merge(:type => input_type, :value => text))
    end
  end
  alias :bootstrap_btn :bootstrap_button

  # Render a bootstrap icon
  # Example code:
  # <tt>
  #   bootstrap_icon('icon-picture')
  # => <i class="icon-picture"></i>
  # </tt>
  def bootstrap_icon icon
    content_tag(:i, '', :class => icon)
  end

  # Render a bootstrap label component
  # Example code:
  # <tt>
  #   bootstrap_label('label text')
  # => <span class="label">label text</span>
  #
  #   bootstrap_label('label text', :info)
  # => <span class="label label-info">label text</span>
  # </tt>
  def bootstrap_label *args
    text, type = args.slice!(0,2)
    bootstrap_widget text, :label, type, *args
  end

  # Render a bootstrap badges component
  # Example code:
  # <tt>
  #   bootstrap_badges('badges text')
  # => <span class="badges">badges text</span>
  #
  #   bootstrap_label('badges text', :info)
  # => <span class="badges badges-info">badges text</span>
  # </tt>
  def bootstrap_badge *args
    text, type = args.slice!(0,2)
    bootstrap_widget text, :badge, type, *args
  end

  # Render a bootstrap alert component
  # Example
  # <tt>
  #   bootstrap_alert
  # </tt>
  def bootstrap_alert *args, &block
    options = args.extract_options!
    type = args.slice!(0)
    with_close = !!options.delete(:with_close)
    append_class_for_options(options,"alert")
    options[:tag] ||= :div
    bootstrap_widget nil, :alert, type, options do
      concat content_tag(:a, :href=>'#', :class => "close", "data-dismiss"=>"alert"){
        "&times;".html_safe
      } if with_close
      concat args.first
      instance_exec(&block) if block_given?
    end
  end

  # Render a bootstrap list
  # Example code:
  # <tt>
  #   bootstrap_list({:attr1=>["h_name1", 1], :attr2=>["h_name2", 2]})
  # => <ul class="unstyled">
  #      <li>h_name1: 1</li>
  #      <li>h_name2: 2</li>
  #    </ul>
  #
  #   bootstrap_list({:attr1=>["h_name1", 1], :attr2=>["h_name2", 2]}) do |attr, values|
  #     values[1] = values[1] + 1 if attr == :attr1
  #     values[1] = values[1]*2 if attr == :attr2
  #     concat content_tag(:li, values.join(" = "))
  #   end
  # => <ul class="unstyled">
  #      <li>h_name1 = 2</li>
  #      <li>h_name2 = 4</li>
  #    </ul>
  #
  #   bootstrap_list({:attr1=>["h_name1", 1], :attr2=>["h_name2", 2]}, :direction => :horizontal)
  # => <ul class="unstyled inline">
  #      <li>h_name1: 1</li>
  #      <li>h_name2: 2</li>
  #    </ul>
  #
  #   bootstrap_list({:attr1=>["h_name1", 1], :attr2=>["h_name2", 2]}, :direction => :horizontal, :tag => :ol)
  # => <ol class="unstyled inline">
  #      <li>h_name1: 1</li>
  #      <li>h_name2: 2</li>
  #    </ol>
  #
  #   bootstrap_list({:attr1=>["h_name1", 1], :attr2=>["h_name2", 2]}, :direction => :vertial)
  # => <div>
  #      <dl class="dl-horizontal">
  #      <dt>h_name1</dt>
  #      <dd>1</dd>
  #      <dt>h_name2</dt>
  #      <dd>2</dd>
  #      </dl>
  #    </div>
  # </tt>
  def bootstrap_list data, options = {}, &block
    direction = options.delete(:direction) || ""
    case direction.to_sym
    when :horizontal
      bootstrap_horizontal_list data, options, &block
    when :vertical
      bootstrap_vertial_list data, options, &block
    else
      tag = options.delete(:tag) || :ul
      append_class_for_options(options,"unstyled")
      block ||= Proc.new{|attr, val| concat content_tag(:li, val.join(": ")) }
      content_tag(tag, options) do
        data.each do |attr, val|
          instance_exec attr, val, &block
        end
      end
    end
  end

  # Render a bootstrap list in horizontal direction
  # See also #bootstrap_list
  def bootstrap_horizontal_list data, options = {}, &block
    tag = options.delete(:tag) || :ul
    append_class_for_options(options,%w[inline unstyled])

    block ||= Proc.new{|attr, val|
      concat content_tag(:li, val[0])
      concat content_tag(:li, val[1])
    }

    content_tag(tag, options) do
      data.each do |attr, val|
        instance_exec attr, val, &block
      end
    end
  end

  # Render a bootstrap list in vertial direction  with .dl-horizontal tags
  # See also #bootstrap_list
  def bootstrap_vertial_list data, options = {}, &block
    append_class_for_options(options, "dl-horizontal")
    block ||= Proc.new{|attr, val| 
      concat content_tag(:dt, val[0])
      concat content_tag(:dd, val[1])
    }

    content_tag(:div) do
      data.each do |attr, val|
        concat content_tag(:dl, options){
          instance_exec attr, val, &block
        }
      end
    end
  end

  private
  def nav_collapse
    content_tag(:a, :class=>"btn btn-navbar", :"data-target"=>".nav-collapse", :"data-toggle"=>"collapse") do
      (1..3).each{|i| concat(content_tag :span,"", :class=>"icon-bar")}
    end
  end

  def bootstrap_widget *args, &block
    options = args.extract_options!
    tag = options.delete(:tag) || :span
    text, type, subtype = args.slice!(0,3)
    subtype = "#{type}-#{subtype}" if subtype
    append_class_for_options(options, [type, subtype])
    content_tag(tag, text, options, &block)
  end

  def append_class_for_options options, css_class
    if options.is_a?(Hash)
      css_class = [css_class].flatten.compact
      options[:class] = [options[:class]].flatten.compact.unshift(*css_class).join(" ")
    end
  end

end
