module ActAsAdmin::Components
  class Form

    attr_reader :input_fields, :form_config
    delegate :action, :as, :method, :url, :to=>:form_config

    def initialize input_fields, form_config
      @input_fields = input_fields
      @form_config = form_config
    end
  end
end