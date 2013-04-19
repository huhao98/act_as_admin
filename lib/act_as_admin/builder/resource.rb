module ActAsAdmin::Builder
  class Resource
    include ::ActAsAdmin::Builder::Dsl

    attr_reader :query_from_proc
    field :resource_attrs, :key=> :true, :proc => :value
    field :parents, :key=> true

    def query_from &block
      @query_from_proc = block
    end

  end
end