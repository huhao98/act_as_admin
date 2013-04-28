require 'spec_helper'

describe ActAsAdmin::Controller::Query do
  setup_context
  let(:controller) do
    controller = mock("Controller")
    controller.extend(::ActAsAdmin::Controller::Query)
    controller.instance_variable_set("@context", context)
    controller
  end

  describe "query_by" do
    it "should raise error when :from option is not presented" do
      expect{controller.query_by query}.to raise_error
    end
  end

end
