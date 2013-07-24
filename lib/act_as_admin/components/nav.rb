module ActAsAdmin::Components

  class Nav

    attr_reader :item_renderer, :group_renderer, :role_verifier

    class << self
      def render nav_items=nil
        nav = ActAsAdmin::Components::Nav.new
        yield(nav)
        nav_items ||= Rails.configuration.nav.nav_items || []
        nav_items.collect do |k, cfg|
          nav.render_item k,cfg
        end
      end
    end


    def item &block
      @item_renderer = block
    end

    def group &block
      @group_renderer = block
    end

    def verify_role &block
      @role_verifier = block
    end

    def render_item key, cfg, opts={}
      if cfg[:with_role].present?
        return unless role_verifier.call(cfg[:with_role])
      end

      unless (cfg[:nav].nil?)
        render_group key, cfg
      else
        item_renderer.call(key, cfg, opts)
      end
    end

    def render_group key, cfg
      buffer = Array.new
      active = false
      cfg[:nav].nav_items.each do |k, cfg|
        opts = {}
        buffer << render_item(k, cfg, opts)
        active ||= opts[:active]
      end
      group_renderer.call(key, cfg, buffer, active)
    end

  end

end
