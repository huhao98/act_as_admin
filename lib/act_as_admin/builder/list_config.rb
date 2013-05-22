module ActAsAdmin::Builder

  class ListConfig
    attr_reader :opts, :actions

    def initialize opts={}
      @opts = opts
    end

    def action name, opts={}, &url_proc
      @actions ||= Hash.new
      opts = opts.merge(:url => url_proc) if block_given?
      @actions[name]=opts
    end

  end
  
end
