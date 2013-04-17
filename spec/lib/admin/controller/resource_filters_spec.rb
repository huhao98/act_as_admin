require 'spec_helper'

describe ::Admin::Controller::ResourceFilters do
  let(:config){::Admin::Config.new}
  let(:controller) do
    controller = mock("Controller")
    controller.class.stub(:admin_config=>config)
    controller.extend(::Admin::Controller::ResourceFilters)
    controller.extend(::Admin::Helpers::PathHelper)
  end

  before :each do
    class DummyModel; extend ActiveModel::Naming; end
    class PolyDummyModel < DummyModel; end
    class ParentModel < DummyModel; end
    DummyModel.stub(:all=>DummyModel)
  end

  after :each do
    Object.send(:remove_const, :DummyModel)
    Object.send(:remove_const, :PolyDummyModel)
    Object.send(:remove_const, :ParentModel)
  end


  describe 'find parent' do

    it "should have empty parents given no parent configuration" do
      controller.stub(:params=>{:parent_model_id=>"1234"})
      controller.find_parents
      expect(controller.instance_variable_get("@parents")).to be_empty
    end

    it "should find the immediate parent" do
      config.parent ParentModel, :on=>:dummies
      a_parent = ParentModel.new
      controller.stub(:params=>{:parent_model_id=>"1234"})
      ParentModel.should_receive(:find).with("1234").and_return(a_parent)

      controller.find_parents

      expect(controller.instance_variable_get("@parents")).to eq({a_parent=>{:on=>:dummies}})
    end

    it "should find parent chain" do
      config.parent ParentModel, :on=>:dummies
      config.parent DummyModel, :on=>:resources

      dummies = mock("Dummy Collection")
      a_parent = ParentModel.new
      a_dummy = DummyModel.new

      ParentModel.should_receive(:find).with("a_parent").and_return(a_parent)
      a_parent.should_receive(:dummies).and_return(dummies)
      dummies.should_receive(:find).with("a_dummy").and_return(a_dummy)

      controller.stub(:params=>{:dummy_model_id=>"a_dummy", :parent_model_id=>"a_parent"})
      controller.find_parents

      expect(controller.instance_variable_get("@parents")).to eq({a_parent=>{:on=>:dummies}, a_dummy=>{:on=>:resources}})
    end

    it "should find polymorphic parents" do
      config.parent [DummyModel, PolyDummyModel], :on=>:resources

      a_ploy_dummy = PolyDummyModel.new
      PolyDummyModel.should_receive(:find).with("a_poly_dummy").and_return(a_ploy_dummy)

      controller.stub(:params=>{:poly_dummy_model_id=>"a_poly_dummy"})
      controller.find_parents

      expect(controller.instance_variable_get("@parents")).to eq({a_ploy_dummy=>{:on=>:resources}})
    end
  end


  describe "resource creation" do
    before :each do
      @parent = ParentModel.new
      controller.instance_variable_set("@model", DummyModel)
    end

    describe 'new resource' do
      before :each do
        controller.stub(:params=>{:dummy_model=>{:name=>"dummy_name"}})
      end

      it "should create a new resource" do
        a_dummy = DummyModel.new
        controller.instance_variable_set("@parents", {})

        DummyModel.should_receive(:new).and_return(a_dummy)

        controller.new_resource

        expect(controller.instance_variable_get("@resource")).to eq(a_dummy)
      end

      it "should create a new resource and assign parent to the parent field" do
        a_dummy = DummyModel.new
        controller.instance_variable_set("@parents", {@parent=>{:on=>:dummies}})

        DummyModel.should_receive(:new).with(:name=>"dummy_name").and_return(a_dummy)
        a_dummy.should_receive(:parent_model=).with(@parent)

        controller.new_resource

        expect(controller.instance_variable_get("@resource")).to eq(a_dummy)
      end
    end

    describe 'find resource' do
      before :each do
        controller.stub(:params=>{:id=>"a_dummy"})
      end

      it "should find resource from model class given there is no parents" do
        a_dummy = DummyModel.new
        controller.instance_variable_set("@parents", {})

        DummyModel.should_receive(:find).with("a_dummy").and_return(a_dummy)

        controller.find_resource

        expect(controller.instance_variable_get("@resource")).to eq(a_dummy)
      end

      it "should find resource from parent" do
        a_dummy = DummyModel.new
        controller.instance_variable_set("@parents", {@parent=>{:on=>:dummies}})

        dummy_collection = mock("dummy collection on parent")
        @parent.should_receive(:dummies).and_return(dummy_collection)
        dummy_collection.should_receive(:find).with("a_dummy").and_return(a_dummy)

        controller.find_resource

        expect(controller.instance_variable_get("@resource")).to eq(a_dummy)
      end
    end

    describe 'find resources' do
      let(:query){mock("Query", :as=>:dummy)}
      before(:each){controller.instance_variable_set("@query", query)}

      it "should find resources from model given there is no parents" do
        resources = mock("Resources")
        controller.instance_variable_set("@parents", {})
        controller.should_receive(:query_by).with(query, :from=>DummyModel).and_return(resources)

        controller.find_resources

        expect(controller.instance_variable_get("@resources")).to eq(resources)
      end

      it "should find resources from parent given parents presented" do
        resources = mock("Resources")
        dummy_collection = mock("dummy collection on parent")

        controller.instance_variable_set("@parents", {@parent=>{:on=>:dummies}})
        @parent.should_receive(:dummies).and_return(dummy_collection)
        controller.should_receive(:query_by).with(query, :from=>dummy_collection).and_return(resources)

        controller.find_resources

        expect(controller.instance_variable_get("@resources")).to eq(resources)
        expect(controller.instance_variable_get("@dummy")).to eq(resources)
      end
    end

    describe 'breadcrumbs' do
      it "should include parent breadcrumbs given parents presented" do
        dummy = DummyModel.new
        page = mock("Page", :breadcrumbs=>{"Dummy"=>{:path=>Proc.new{resources_path}}})
        @parent.stub(:parent_name=>"A Parent")

        controller.should_receive(:parent_models_path).with({}).and_return("/parents")
        controller.should_receive(:parent_model_path).with(@parent, {}).and_return("/parents/a_parent")
        controller.should_receive(:parent_model_dummy_models_path).with(@parent, {}).and_return("/parents/a_parent/dummies")

        controller.should_receive(:add_breadcrumb).with("Parent model", "/parents")
        controller.should_receive(:add_breadcrumb).with("A Parent", "/parents/a_parent")
        controller.should_receive(:add_breadcrumb).with("Dummy", "/parents/a_parent/dummies")

        controller.instance_variable_set("@parents", {@parent=>{:on=>:dummies, :title_field=>:parent_name}})
        controller.instance_variable_set("@resource", dummy)
        controller.instance_variable_set("@page", page)

        controller.breadcrumbs
      end

      it "should generate breadcrumbs from page configuration" do
        dummy = DummyModel.new
        page = mock("Page", :breadcrumbs=>{"Dummy"=>{:path=>Proc.new{resources_path}}})

        controller.should_receive(:dummy_models_path).with({}).and_return("/dummies")
        controller.should_receive(:add_breadcrumb).with("Dummy", "/dummies")

        controller.instance_variable_set("@parents", {})
        controller.instance_variable_set("@resource", dummy)
        controller.instance_variable_set("@page", page)

        controller.breadcrumbs
      end

      it "should generate breadcrumbs with title that is configurated as a Proc" do
        dummy = DummyModel.new
        breadcrumb_title = ->{"Dummy Title"}
        page = mock("Page", :breadcrumbs=>{breadcrumb_title=>{:path=>Proc.new{resource_path(@resource)}}})

        controller.should_receive(:dummy_model_path).with(dummy,{}).and_return("/dummies/a_dummy")
        controller.should_receive(:add_breadcrumb).with("Dummy Title", "/dummies/a_dummy")

        controller.instance_variable_set("@parents", {})
        controller.instance_variable_set("@resource", dummy)
        controller.instance_variable_set("@page", page)

        controller.breadcrumbs
      end

    end
  end
end
