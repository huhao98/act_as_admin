module ActAsAdmin::Builder

  class ListConfig
    include ActAsAdmin::Builder::Dsl

    attr_reader :opts, :actions
    field :actions, :proc=>:url

    def self.clone list_config, opts={}
      new_list_config = list_config.clone
      new_list_config.opts.merge!(opts)
      return new_list_config
    end

    def initialize opts={}
      @opts = opts
    end
  end
  
end
