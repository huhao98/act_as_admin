module ActAsAdmin::Controller
  module Query
    extend ActiveSupport::Concern
    
    included do
      before_filter :find_resources
    end


    def find_resources
      query = @context.page.queries[:default]
      return unless query

      @query_result = query_by(query, :from => resolve(query.from || @context.collection))
      @resources = @query_result.items
      instance_variable = query.as
      self.instance_variable_set("@#{instance_variable}", @resources) if instance_variable
    end

    def query_by query_config, opts={}
      from = opts[:from]
      raise "No search from" if from.nil?

      return ActAsAdmin::Query::MongoQueryExecutor.new(from, query_config)
        .filter(params[:f])
        .order(params[:o])
        .paginate(params[:page])
        .result
    end

    private

    def resolve value
      resolved = self.instance_exec(&value) if value.is_a? Proc
      return resolved || value
    end

  end

end
