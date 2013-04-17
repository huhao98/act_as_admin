module Admin::Builder
  
  class Form
    include ::Admin::Builder::Dsl
    attr_accessor :as, :partial
    attr_reader :options, :groups, :actions

    field :fields, :inherit=>true, :key=> true
    field :actions, :key=>true, :proc=>:action_url

    def group name
      fields[:name]={:type=>:group}
      yield() if block_given?
    end

  end

end
