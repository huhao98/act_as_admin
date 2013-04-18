module ActAsAdmin::Controller

  module Query

    def query_by query, opts={}
      if query.on
        criteria = self.instance_exec(&query.on)
      else
        criteria = opts[:from]
      end
      
      #{:s=>:active}
      default_scope = query.default_scope || []
      applied_scope = params[:s] || default_scope[0]
      scopes=query.scopes.symbolize_keys
      condition = (scopes[applied_scope.to_sym] || {})[:condition] if applied_scope
      if condition.present?
        criteria = condition.call(criteria)
        @applied_scope = applied_scope.to_sym
      end

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

  end
  
end
