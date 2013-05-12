module ActAsAdmin::Builder
  class Resource
    include ::ActAsAdmin::Builder::Dsl

    attr_reader :query_from_proc, :parent_fields

    # field(:parent, :when=>:new, :parent_model=>Parent)
    # field(:orders, :when=>:new){current_user.orders}
    
    field :fields, :key=> :true, :proc => :value
    field :parents, :key=> true

    def query_from &block
      @query_from_proc = block
    end

    def parent_field name, parent_model, opts={}
      field name, opts.merge(:parent_class=>parent_model)
    end

  end
end