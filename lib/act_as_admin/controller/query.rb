module ActAsAdmin::Controller

  module Query
    def query_by query_config, opts={}
      from = opts[:from]
      raise "No search from" if from.nil?

      return MongoQueryExecutor.new(from, query_config).
          filter(params[:f]).
          order(params[:o]).
          paginate(params[:page]).
          result

      #return MongoQuery.new(from, query_config).filter(params[:f]).order(params[:o]).paginate(params[:page])
    end
  end

end
