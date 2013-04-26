module ActAsAdmin::Builder
  class Query
    include ::ActAsAdmin::Builder::Dsl
    attr_reader :path_proc, :per_page, :from, :opts 
    field :filters, :key=> :field, :proc => :condition
    field :orders, :key=> :field

    def initialize opts={}
      @opts = opts
    end

    def as
      return opts[:as]
    end

    def query_from &from
      @from = from
    end

    # Set path helper that should be executed in a context which have path helper
    def query_path &block
      @path_proc = block
    end

    def page per_page
      @per_page = per_page
    end   

    def default_order
      default = orders.select{|k,v| v[:default]}
      return default.first unless default.empty?
    end
    
  end
end
