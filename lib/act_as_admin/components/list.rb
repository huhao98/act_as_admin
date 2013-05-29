module ActAsAdmin::Components

  class << self
    def list name
      resource_config = ActAsAdmin::Builder::ResourceConfig.new name
      list_config = ActAsAdmin::Builder::ListConfig.new
      yield(resource_config, list_config)
      ActAsAdmin::Components::List.new(resource_config.find_formatters, list_config)
    end
  end

  class List
    attr_reader :formatters, :list_config
    delegate :actions, :to=>:list_config

    def initialize formatters, list_config
      @formatters = formatters
      @list_config = list_config
    end

    def scope 
      list_config.opts[:scope]
    end
  end
end