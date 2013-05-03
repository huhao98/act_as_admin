require 'spec_helper'

describe ::ActAsAdmin::Controller::Base do
  setup_context

  let(:controller) do
    controller = mock("Controller")
    controller.extend(::ActAsAdmin::Controller::Base)
    controller.extend(::ActAsAdmin::Helpers::PathHelper)
    controller.instance_variable_set("@context", context)
    controller.class.stub!(:admin_config=>config)
    controller
  end

  describe 'new_resource' do
    before :each do
      new_dummy = dummy
      Dummy.should_receive(:new).with({:name=>"dummy"}).and_return(new_dummy)
      controller.stub(:params=>{:dummy=>{:name=>"dummy"}})
      context.stub(:model=>Dummy, :fields=>"")
    end

    it "should create a new resource" do
      controller.new_resource
      resource = controller.instance_variable_get("@resource")
      expect(resource).to eq(dummy)
    end

    it "should assign fields when creating new resource" do
      context.should_receive(:fields){|&proc| proc.call(:name, "assigned name")}

      controller.new_resource
      resource = controller.instance_variable_get("@resource")
      expect(resource).to eq(dummy)
      expect(resource.name).to eq("assigned name")
      iv = controller.instance_variable_get("@#{context.config.resource_name}")
      expect(iv).to eq(resource)
    end

    it "should assign fields with resovled proc value when creating new resource" do
      context.should_receive(:fields) do |&proc|
        value = ->{"proc value"}
        proc.call(:name, value)
      end

      controller.new_resource
      resource = controller.instance_variable_get("@resource")
      expect(resource).to eq(dummy)
      expect(resource.name).to eq("proc value")
    end
  end


  describe 'find_resource' do
    let (:from){mock("From Query")}

    before :each do
      controller.stub(:params=>{:id=>"dummy_id"})
      context.stub(:model=>Dummy)
      from.stub!(:find).with("dummy_id").and_return(dummy)
    end

    it "should find resource by id" do
      context.should_receive(:find_from).and_return(from)

      controller.find_resource
      expect(controller.instance_variable_get("@resource")).to eq(dummy)
      iv = controller.instance_variable_get("@#{context.config.resource_name}")
      expect(iv).to eq(dummy)
    end

    it "should resolve from_query" do
      from_query = from
      context.should_receive(:find_from).and_return(->{from_query})

      controller.find_resource
      expect(controller.instance_variable_get("@resource")).to eq(dummy)
    end
  end

  describe 'find_resources' do
    let(:from){mock("From Query")}
    let(:query){mock("Query", :as=>:dummy, :from=>nil)}
    before(:each) do
      controller.stub(:params=>{:o=>"name"})
      context.stub(:model=>Dummy, :query=>query, :find_from=>from)
    end

    it "should query results from context's find_from" do
      items = mock("items")
      results = mock("Results", :items=>items)
      controller.should_receive(:query_by).with(query, :from=>from).and_return(results)

      controller.find_resources

      expect(controller.instance_variable_get("@resources")).to eq(items)
    end

    it "should query results from query's from when it is presented" do
      query_from = mock("Query From")
      query.stub!(:from=>query_from)
      controller.should_receive(:query_by).with(query, :from=>query_from).and_return(mock("Results", :items=>"items"))

      controller.find_resources
    end

    it "should assign queried results as an instance variable specified by the query " do
      query.stub(:as=>:dummies)
      items = mock("items")
      results = mock("Results", :items=>items)

      controller.should_receive(:query_by).with(query, :from=>from).and_return(results)
      controller.find_resources

      expect(controller.instance_variable_get("@resources")).to eq(items)
      expect(controller.instance_variable_get("@dummies")).to eq(items)
    end


  end

  describe "create" do
    before :each do
      format = mock(:format)
      format.stub(:html){|&block| block.call }
      controller.stub(:respond_to){|&block| block.call format }
      controller.instance_variable_set("@resource", dummy)
      dummy.stub(:save=>true)
    end

    it "should redirect to resources path after successful create" do
      controller.should_not_receive(:parent_path)
      controller.should_receive(:resources_path).and_return("resources_path")
      controller.should_receive(:redirect_to).with("resources_path", an_instance_of(Hash))
      controller.create
    end

    it "should redirect to parent path after successful create when exclude_nested_index is true" do
      context.stub(:"exclude_nested_index?" => true)

      controller.should_receive(:parent_path).and_return("parent_path")
      controller.should_not_receive(:resources_path)
      controller.should_receive(:redirect_to).with("parent_path", an_instance_of(Hash))
      controller.create
    end
  end


end
