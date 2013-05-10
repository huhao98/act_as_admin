module ActAsAdmin::Helpers
  
  class QueryParams
    attr_reader :query_params, :filters, :orders

    class Freezer
      attr_reader :params
      def initialize(params, &url_helper)
        @params = params.freeze
        @url_helper = url_helper
      end

      def url
        @url_helper.call(params)
      end
    end

    def initialize query_params, filters, orders, &url_helper
      @query_params = query_params
      @filters = filters || {}
      @orders = orders || {}
      @url_helper = url_helper
    end

    def filter_value field
      return (@query_params[:f] || {})[field]
    end

    def order_value field
      current = (@query_params[:o] || {})[field]
      {"desc"=>"asc", "asc"=>"desc"}[current] unless (current.nil?)
    end

    def filter field, value=nil
      p = @query_params.clone
      p[:f] = (p[:f] || {}).clone
      if (value.nil?)
        p[:f].except!(field)
      else
        p[:f].merge!(field =>value)
      end
      return freeze(p)
    end

    def order(field, value, default=nil)
      p = @query_params.clone
      dir = order_value(field) || default || "asc"
      p.merge!(:o=> {field => dir})
      return freeze(p)
    end

    def url
      @url_helper.call()
    end

    private
    def freeze(params)
      return Freezer.new(params, &@url_helper)
    end
  end
end
