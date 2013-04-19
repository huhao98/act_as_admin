module ActAsAdmin::Controller
  class Context
    attr_reader :config, :page, :query, :form
    delegate :model, :resource, :to=>:config

    def initialize action, config
      @config = config
      @action = action
      @page = config.pages[action] || config.default_page
      @query = config.queries[action]
      @form = config.forms[action]
    end

  end
end