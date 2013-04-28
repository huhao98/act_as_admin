module ActAsAdmin::Helpers

  class NavConfig
    attr_reader :nav_items

    def configure &block
      yield(self)
    end

    def nav name, opts={}, &block
      @nav_items ||= {}
      opts = opts.merge(:url=>block) if block_given?
      @nav_items[name] = opts
    end
  end

end
