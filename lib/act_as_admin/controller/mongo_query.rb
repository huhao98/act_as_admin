module ActAsAdmin::Controller

  class MongoQuery
    attr_reader :query, :query_params, :query_meta_data
    attr_reader :items    

    def initialize(from, query)
      @from = from
      @query = query
      @query_params = {}
    end

    def order order_params=nil
      order_params ||= {}
      #{:o=>{:created_at,"asc"}}
      default_order = query.default_order
      applied_orders = order_params.select{|field, dir| query.orders.keys.include? field.to_sym}

      if (applied_orders.blank? && default_order.present?)
        applied_orders = {default_order[0] => default_order[1][:dir]}
      end

      if applied_orders.present?
        @from = @from.order_by(applied_orders.collect{|field, dir| [field.to_sym, dir]})
        apply_orders(applied_orders.symbolize_keys)
      end
      return self
    end

    def filter filter_params=nil
      update_query_meta_data

      #{:f=>{:type=>"soft", :price=>[20,50]}}
      filter_params ||= {}
      filter_params.symbolize_keys.each_pair do |field, value|
        next unless query.filters.keys.include? field
        opts = query.filters[field]
        condition = opts[:condition] || default_filter_proc(field, opts[:type])
        @from = condition.call(@from, value)
        apply_filter(field, value)
      end
      return self
    end

    def paginate page
      per_page = query.per_page || 10
      @items = @from.paginate(:page=> page , :per_page=>per_page)
      return self
    end

    private

    def update_query_meta_data
      @query_meta_data ||= {}
      query.filters.each do |field, opts|
        if [:select, :scope].include?(opts[:type]) && opts[:values].nil?
          values = @from.distinct(field)
          @query_meta_data[field] ||= {}
          @query_meta_data[field].merge!(:values=>values)
        end
      end      
    end

    def default_filter_proc field, type
      case type
      when :select, :scope
        Proc.new{|c,v| c.where(field=>v)}

      when :range
        Proc.new do |c,v| 
          range=v.collect(&:to_f); 
          c.where(field.gte=>range.min, field.lte=>range.max)
        end

      else
        Proc.new{|c, v| c.any_of(field=> /#{v}/i )}
      end
    end

    def apply_orders applied_orders
      @query_params[:o] = applied_orders || {}
    end

    def apply_filter field, value
      @query_params[:f] ||= {}
      @query_params[:f][field.to_sym] = value
    end
    

  end

end
