module ActAsAdmin::Helpers

  class NavConfig
    attr_reader :nav_items

    def configure &block
      yield(self)
      return self
    end

    def nav name, opts={}, &block
      @nav_items ||= {}
      opts = opts.merge(:url=>block) if block_given?
      @nav_items[name] = opts
    end

    def group name, opts={}, &block
      group_config = NavConfig.new
      yield(group_config)
      @nav_items[name] = opts.merge(:nav=>group_config)
    end
    
  end

end
