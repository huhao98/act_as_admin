require 'spec_helper'

describe ::ActAsAdmin::Controller::Base do

  def setup_controller params
    format = mock(:format)
    format.stub(:html){|&block| block.call}
    
    config = ActAsAdmin::Config.new(:model=>::Dummy, :resource_name=>"dummy")
    config.resource{path(:dummies)}

    controller = mock("Controller", :params=>params.with_indifferent_access)
    controller.extend(::ActAsAdmin::Controller::Base)
    controller.extend(::ActAsAdmin::Helpers::PathHelper)
    controller.stub(:respond_to){|&block| block.call format }
    controller.class.stub!(:admin_config=>config)

    yield(config) if block_given?
    controller.init_context
    return controller
  end


  describe 'new_resource' do
    it "should create a new resource" do
      controller = setup_controller(:action=>"new")

      controller.new_resource

      resource = controller.instance_variable_get("@resource")
      expect(resource).to eq(dummy)
    end

    it "should assign fields when creating new resource" do
      controller = setup_controller(:action=>"new") do |config|
        config.resource_config.field(:name).assign{"assigned name"}
      end

      controller.new_resource

      resource = controller.instance_variable_get("@resource")
      expect(resource).to eq(dummy)
      expect(resource.name).to eq("assigned name")
      expect(controller.instance_variable_get("@dummy")).to eq(resource)
    end
  end


  describe 'find_resource' do
    it "should find resource by id" do
      controller = setup_controller("id"=>"dummy_id", :action=>"show")

      controller.find_resource

      expect(controller.instance_variable_get("@resource")).to eq(dummy)
      expect(controller.instance_variable_get("@dummy")).to eq(dummy)
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

  describe "create" do
    before :each do
      dummy.stub(:save=>true)
    end

    it "should redirect to resources path after successful create" do
      controller = setup_controller(:action=>"create")
      controller.instance_variable_set("@resource", dummy)

      controller.should_receive(:dummies_path).and_return("dummies_path")
      controller.should_receive(:redirect_to).with("dummies_path", an_instance_of(Hash))
      controller.create
    end

    it "should redirect to parent path after successful create when exclude index" do
      albums_collection = mock("Albums", :find=>"album")
      dummy.stub(:albums=>albums_collection)
      controller = setup_controller(:action=>"create", :dummy_id=>"dummy_id") do |config|
        config.resource do
          path(:dummies).to(:albums, :exclude=>[:index])
        end
      end

      controller.instance_variable_set("@resource", dummy)
      controller.should_receive(:dummy_path).with(dummy).and_return("dummy_path")
      controller.should_receive(:redirect_to).with("dummy_path", an_instance_of(Hash))

      controller.create
    end
  end


end
