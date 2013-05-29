require 'spec_helper'

describe ActAsAdmin::Controller::Query do
  def setup_controller params
    config = ActAsAdmin::Config.new(:model=>::Dummy, :resource_name=>"dummy")
    config.resource{path(:dummies)}

    controller = mock("Controller", :params=>params.with_indifferent_access)
    controller.extend(::ActAsAdmin::Controller::Base)
    controller.extend(::ActAsAdmin::Controller::Query)
    controller.extend(::ActAsAdmin::Helpers::PathHelper)
    controller.class.stub!(:admin_config=>config)

    yield(config) if block_given?
    controller.init_context
    return controller
  end

  describe "query_by" do
    let(:controller) do
      setup_controller(:action=>"index") do |config|
        config.page(:index){ query{} }
      end
    end

    it "should raise error when :from option is not presented" do
      expect{controller.query_by query}.to raise_error
    end
  end

  describe 'find_resources' do
    let(:items){mock("Items")}
    let(:query_result){mock("Query result", :items=>items)}
    let(:controller) do
      setup_controller(:action=>"index") do |config|
        config.page(:index){ query{} }
      end
    end

    it "should query results from collection" do
      controller.should_receive(:query_by).with(
      controller.class.admin_config.pages[:index].queries[:default], :from=>Dummy.all).and_return(query_result)

      controller.find_resources
      expect(controller.instance_variable_get("@resources")).to eq(items)
    end

    it "should query results from query's from when it is presented" do
      query_from = mock("Query From")
      controller.class.admin_config.page(:index) do
        query do
          query_from { query_from }
        end
      end

      controller.should_receive(:query_by).with(
      controller.class.admin_config.pages[:index].queries[:default], :from=>query_from).and_return(query_result)

      controller.find_resources
      expect(controller.instance_variable_get("@resources")).to eq(items)
    end

    it "should assign queried results as an instance variable specified by the query " do
      controller.class.admin_config.page(:index) do
        query(:as=>:dummies)
      end

      controller.should_receive(:query_by).with(
      controller.class.admin_config.pages[:index].queries[:default], :from=>Dummy.all).and_return(query_result)

      controller.find_resources
      expect(controller.instance_variable_get("@resources")).to eq(items)
      expect(controller.instance_variable_get("@dummies")).to eq(items)
    end
  end

end
