module ActAsAdmin::Builder
  class QueryConfig
    include ::ActAsAdmin::Builder::Dsl
    
    attr_reader :path_proc, :per_page, :from, :opts
    field :filters, :key=> :field, :proc => :condition
    field :orders, :key=> :field

    def self.clone query_config, opts={}
      new_query_config = query_config.clone
      new_query_config.opts.merge!(opts)
      return new_query_config
    end

    def initialize opts={}
      @opts = opts
    end

    def as
      return opts[:as]
    end

    def page per_page
      @per_page = per_page
    end 

    def query_from &from
      @from = from
    end

    # Set path helper that should be executed in a context which have path helper
    def query_path &block
      @path_proc = block
    end

    def default_order
      default = orders.select{|k,v| v[:default]}
      return default.first unless default.empty?
    end
    
  end
end
