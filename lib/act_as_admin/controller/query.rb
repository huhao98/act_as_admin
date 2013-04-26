module ActAsAdmin::Controller

  module Query
    def query_by query, opts={}
      from = opts[:from]
      raise "No search from" if from.nil?
      return MongoQuery.new(from, query).filter(params[:f]).order(params[:o]).paginate(params[:page])
    end
  end

end
