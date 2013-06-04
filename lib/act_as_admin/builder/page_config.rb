module ActAsAdmin::Builder

  class PageConfig
    include ActAsAdmin::Builder::Dsl

    attr_accessor :opts
    attr_accessor :forms, :lists, :queries, :breadcrumbs
    field :headers, :proc=>:text
    field :actions, :proc=>:url

    def self.clone page_config, opts={}
      new_page = page_config.clone
      new_page.apply_opts opts
      return new_page
    end

    def initialize opts={}
      @actions = opts.delete(:actions) || {}
      @headers = opts.delete(:headers) || {}
      @forms = opts.delete(:forms) || {}
      @lists = opts.delete(:lists) || {}
      @queries = opts.delete(:queries) || {}
      @breadcrumbs= opts.delete(:breadcrumbs) || []
      apply_opts opts
    end

    def apply_opts opts
      exclude = opts.delete(:exclude) || {}
      [:actions, :headers, :forms, :lists, :queries].each do| prop|
        excludes = [exclude[prop]].flatten.compact
        self.send(prop).reject!{|k,v| excludes.include? k}
      end
      @opts ||= {}
      @opts.merge!(opts)
    end

    def breadcrumb &block
      @breadcrumbs ||= []
      @breadcrumbs << block
    end

    def form *args, &block
      @forms ||= Hash.new
      args(*args) do |name, opts|
        form_config = @forms[name]
        if form_config.nil?
          form_config = ActAsAdmin::Builder::FormConfig.new(opts)
        else
          form_config = ActAsAdmin::Builder::FormConfig.clone(form_config, opts)
        end

        form_config.instance_eval(&block) if block_given?
        @forms[name] = form_config
      end
    end

    def list *args, &block
      @lists ||= Hash.new
      args(*args) do |name, opts|
        list_config = @lists[name]
        if list_config.nil?
          list_config = ActAsAdmin::Builder::ListConfig.new(opts)
        else
          list_config = ActAsAdmin::Builder::ListConfig.clone(list_config, opts)
        end

        list_config.instance_eval(&block) if block_given?
        @lists[name] = list_config
      end
    end

    def query *args, &block
      @queries ||= Hash.new
      args(*args) do |name, opts|
        query_config = @queries[name]
        if query_config.nil?
          query_config = ActAsAdmin::Builder::QueryConfig.new(opts)
        else
          query_config = ActAsAdmin::Builder::QueryConfig.clone(query_config, opts)
        end

        query_config.instance_eval(&block) if block_given?
        @queries[name] = query_config
      end
    end


    private
    def args *args
      raise "invalid argument" if args.size >2

      return yield(:default, {}) if args.size ==0 
      return yield(:default, args[0]) if args.first.respond_to? :map
      return yield(args[0], args[1] || {})
    end

  end
  
end
