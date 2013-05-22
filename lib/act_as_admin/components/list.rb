module ActAsAdmin::Components

  class << self
    def list name
      resource_config = ActAsAdmin::Builder::ResourceConfig.new name
      list_config = ActAsAdmin::Builder::ListConfig.new
      yield(resource_config, list_config)
      ActAsAdmin::Components::List.new(resource_config.find_formatters, list_config.actions)
    end
  end

  class List
    attr_reader :formatters
    attr_reader :actions

    def initialize formatters, actions
      @formatters = formatters
      @actions = actions
    end

    def headers &block
      formatters.each do |formatter|
        yield(formatter.field)
      end
    end

    def row &block
      formatters.each do |field, formatter|
        yield(field, formatter)
      end

    end

  end
end