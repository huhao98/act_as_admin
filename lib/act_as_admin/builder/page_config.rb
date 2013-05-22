
module ActAsAdmin::Builder

  class PageConfig

    attr_accessor :headers, :actions, :groups, :forms, :lists, :queries, :breadcrumbs

    def initialize
      @actions = {}
      @headers = {}
      @groups = {}
      @forms = {}
      @lists = {}
      @queries = {}
      @breadcrumbs=[]
    end

    def breadcrumb &block
      @breadcrumbs ||= []
      @breadcrumbs << block
    end

    def header name, opts={}, &text_proc
      @headers ||= Hash.new
      opts = opts.merge(:text => text_proc) if block_given?
      @headers[name] = opts
    end 
    
    def action name, opts={}, &url_proc
      @actions ||= Hash.new
      opts = opts.merge(:url => url_proc) if block_given?
      @actions[name]=opts
    end

    def group name, opts={}
      @groups ||= Hash.new
      @groups[name]=opts
    end

    def form *args, &block
      @forms ||= Hash.new
      args(*args) do |name, opts|
        form_config = ActAsAdmin::Builder::FormConfig.new(opts, @forms[name])
        form_config.instance_eval(&block) if block_given?
        @forms[name] = form_config
      end
    end

    def list *args, &block
      @lists ||= Hash.new
      args(*args) do |name, opts|
        list_config = ActAsAdmin::Builder::ListConfig.new(opts)
        list_config.instance_eval(&block) if block_given?
        @lists[name] = list_config
      end
    end

    def query *args, &block
      @queries ||= Hash.new
      args(*args) do |name, opts|
        query_config = ActAsAdmin::Builder::QueryConfig.new(opts)
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
