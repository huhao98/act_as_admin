module ActAsAdmin::Builder
  class FormConfig

    attr_reader :opts

    def self.clone form_config, opts={}
      new_form_config = form_config.clone
      new_form_config.opts.merge!(opts)
      return new_form_config
    end

    def initialize opts={}, parent=nil
      opts.merge!(parent.opts) if parent
      @opts = opts
    end

    def submit_label
      @opts[:submit]
    end

    def cancel_label
      @opts[:cancel]
    end

    def as
      @opts[:as]
    end

    def fields
      @opts[:fields]
    end

    def method
      @opts[:method]
    end

    def url
      @opts[:url]
    end

    def cancel_url
      @opts[:cancel_url]
    end

    def submit name, opts={}, &url_proc
      opts.merge!(:url => url_proc) if block_given?
      @opts = opts.merge(:submit=>name).merge(@opts)
    end

    def cancel name, opts={}, &url_proc
      opts.merge!(:cancel_url => url_proc) if block_given?
      @opts = opts.merge(:cancel=>name).merge(@opts)
    end

  end
end