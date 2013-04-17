module ActAsAdmin
  class NavConfig
    attr_reader :nav_items

    def initialize
      @nav_items ||= []
    end

    def configure 
      yield self
    end

    def nav_item title, opts={}, &block
      opts[:url] = block if block_given?
      append_nav_item({:title =>title}.merge(opts))
    end

    def nav_model model
      append_nav_item(:model => model)
    end

    def nav_models title, models=[]
      append_nav_item(:title => title, :models => models)
    end

    private 
    def append_nav_item item
      @nav_items << item
    end

  end
end