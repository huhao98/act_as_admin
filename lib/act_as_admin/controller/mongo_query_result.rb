module ActAsAdmin::Controller
  class MongoQueryResult

    attr_reader :criteria, :query_config
    alias_method :query, :query_config

    def initialize criteria, query_config, opts = {}
      @criteria = criteria
      @query_config = query_config
      @opts = opts
    end

    def query_params
      return @opts[:query_params] || {}
    end

    def query_meta_data
      return @opts[:meta_data] || {}
    end

    def page
      @opts[:page] || 1
    end

    def items
      return @items unless @items.nil?
      @items ||= criteria.paginate(:page=> page , :per_page=>(query_config.per_page || 10))
    end

    def all_items
      return criteria.all
    end

    def aggregate opts={}
      collection = criteria.context.collection
      selector = criteria.context.query.selector

      match = selector.merge(opts.delete(:match) || {})
      aggregate = [{"$match" => match}]
      aggregate << {"$sort" => opts[:sort]} if (opts[:sort])
      aggregate << {"$group"=> opts[:group]} if (opts[:group])
      collection.aggregate(aggregate)
    end
  end
end
