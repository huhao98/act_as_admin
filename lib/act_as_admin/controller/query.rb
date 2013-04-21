module ActAsAdmin::Controller

  module Query

    def query_by query, opts={}
      if query.on
        criteria = self.instance_exec(&query.on)
      else
        criteria = opts[:from]
      end
      
      default_scope = query.default_scope || []

      criteria = query_scope_or_keyword query, criteria, "scope", params[:s] || default_scope[0]
      criteria = query_scope_or_keyword query, criteria, "search", params[:q]

      #{:o=>{:created_at,"asc"}}
      default_order = query.default_order
      applied_orders = (params[:o] || {}).select{|field, dir| query.orders.keys.include? field.to_sym}

      if (applied_orders.blank? && default_order.present?)
        applied_orders = {default_order[0] => default_order[1][:dir]}
      end

      if applied_orders.present?
        criteria = criteria.order_by(applied_orders.collect{|field, dir| [field.to_sym, dir]})
        @applied_orders = applied_orders.symbolize_keys
      end

      per_page = query.per_page || 10

      criteria.paginate(:page=> params[:page], :per_page=>per_page)
    end

    def query_scope_or_keyword query, criteria, action, params
      act = query.send(action.pluralize).symbolize_keys
      key = action == "scope" ? params : query.searches.keys[0]
      
      condition = (act[key.to_sym] || {})[:condition] if params
      if condition.present?
        criteria = action == "scope" ? condition.call(criteria) : condition.call(criteria, params)
        self.instance_variable_set(:"@applied_#{action}", key.to_sym)
      end
      criteria
    end

  end
  
end
