require 'spec_helper'

describe ActAsAdmin::Controller::Context do
  setup_config

  describe "exclude_nested_index?" do
    let(:context){ActAsAdmin::Controller::Context.new(config, {:action=>:new})}

    it "should be false when not configurated" do
      config.instance_variable_set("@opts", {})
      context.stub(:parents=>{parent=>{}})
      
      expect(context.exclude_nested_index?).to be_false
    end

    context "when config exclude_nested_index true" do
      before(:each){config.instance_variable_set("@opts", {:exclude_nested_index=>true})}

      it "is false when there are no parents" do
        expect(context.exclude_nested_index?).to be_false
      end

      it "is true when parent exist" do
        context.stub(:parents=>{parent=>{}})
        expect(context.exclude_nested_index?).to be_true
      end
    end
  end

  describe 'parent' do
    it "is the last key of parents" do
      context = ActAsAdmin::Controller::Context.new(config, {:action=>:new})
      context.stub(:parents => {parent=>{}, dummy=>{}})
      expect(context.parent).to eq(dummy)
    end

    it "is nil given parents is empty" do
      context = ActAsAdmin::Controller::Context.new(config, {:action=>:new})
      expect(context.parent).to be_nil
    end
  end

  describe 'find_from' do
    it "is the resource configuration's query_from proc when it is presented" do
      query_from = ->{'Query From'}
      config.resource.query_from &query_from

      context = ActAsAdmin::Controller::Context.new(config, {:action=>:index})
      expect(context.find_from).to eq(query_from)
    end

    it "is the parent's children collection when parent is presented" do
      resources = mock("Resources")
      parent.should_receive(:resources).and_return(resources)

      context = ActAsAdmin::Controller::Context.new(config, {:action=>:index})
      context.stub(:parents => {parent=>{:on=>:resources}})
      expect(context.find_from).to eq(resources)
    end

    it "is the model class when parent is nil and no query_from is set" do
      config.stub(:model=>Dummy)
      resources = mock("Resources")
      Dummy.should_receive(:all).and_return(resources)

      context = ActAsAdmin::Controller::Context.new(config, {:action=>:index})
      context.stub(:parents => {})

      expect(context.find_from).to eq(resources)
    end

  end

  describe 'path_for' do

    let(:context){ActAsAdmin::Controller::Context.new(config, {:action=>:new})}

    it "should yield plural resource path helper name" do
      expect{|b| context.path_for &b}.to yield_with_args(:dummies_path)
    end

    it "should yield singular resource path helper name" do
      expect{|b| context.path_for :singular=>true, &b}.to yield_with_args(:dummy_path)
    end

    it "should yield nested plural resource path helper name" do
      context.stub!(:parents=>{parent=>{:resource_name=>"parent"}})
      expect{|b| context.path_for &b}.to yield_with_args(:parent_dummies_path, parent)
    end

    it "should yield nested singular resource path helper name" do
      context.stub!(:parents=>{parent=>{:resource_name=>"parent"}})
      expect{|b| context.path_for :singular=>true, &b}.to yield_with_args(:parent_dummy_path, parent)
    end

    it "should prepend action to the resource path helper name" do
      expect{|b| context.path_for :singular=>true, :action=>:new, &b}.to yield_with_args(:new_dummy_path)
    end

    it "can override the resource name" do
      expect{|b| context.path_for :resource=>'test', &b}.to yield_with_args(:tests_path)
    end

    it "can override the parents" do
      context.stub!(:parents=>{
                      parent=>{:resource_name=>"parent"},
                      dummy => {:resource_name=>"dummy"}
      })

      expect{|b| context.path_for :resource=>'test', &b}.to yield_with_args(
      :parent_dummy_tests_path, parent, dummy)

      expect{|b| context.path_for :parents=>[parent], :resource=>'test', &b}.to yield_with_args(
      :parent_tests_path, parent)
    end

  end

  describe 'fields' do
    specify "take a block to assign field name and value" do
      config.resource.field(:orders, :value=>"orders value")

      context = ActAsAdmin::Controller::Context.new(config, {:action=>:new})
      expect{|b| context.fields &b}.to yield_with_args(:orders, "orders value")
    end

    specify "value can be a proc" do
      config.resource.field(:orders){"orders value"}

      context = ActAsAdmin::Controller::Context.new(config, {:action=>:new})
      expect{|b| context.fields &b}.to yield_with_args(:orders, Proc)
    end

    specify "don't assign fields that is not belongs to current action" do
      config.resource.field(:orders, :when=>:test, :value=>"orders value")

      context = ActAsAdmin::Controller::Context.new(config, {:action=>:new})
      expect{|b| context.fields &b}.not_to yield_control
    end

    specify "will assign parent field with matching parent in the context" do
      config.resource.parent_field :parent, Parent

      context = ActAsAdmin::Controller::Context.new(config, {:action=>:new})
      context.stub(:parents=>{parent=>{:on=>:resources}})

      expect{|b| context.fields &b}.to yield_with_args(:parent, parent)
    end
  end
  

  describe 'describe initialize' do

    specify "page is selected by action" do
      config.page(:test){}
      context = ActAsAdmin::Controller::Context.new(config, {:action=>:test})
      expect(context.page).to eq(config.pages[:test])
    end

    specify "default page is selected when no page was assigned for the action" do
      context = ActAsAdmin::Controller::Context.new(config, {:action=>:test})
      expect(context.page).to eq(config.default_page)
    end

    specify "query is selected by action" do
      config.query(:action=>:test){}
      expect(ActAsAdmin::Controller::Context.new(config, {:action=>:test}).query).to eq(config.queries[:test])
      expect(ActAsAdmin::Controller::Context.new(config, {:action=>:another_test}).query).to be_nil
    end

    specify "form is selected by action" do
      config.form(:action=>:test){}
      expect(ActAsAdmin::Controller::Context.new(config, {:action=>:test}).form).to eq(config.forms[:test])
      expect(ActAsAdmin::Controller::Context.new(config, {:action=>:another_test}).form).to be_nil
    end

    specify "delegate :model and :resource to config" do
      context = ActAsAdmin::Controller::Context.new(config, {:action=>:test})
      expect(context.resource).not_to be_nil
      expect(context.resource).to eq(config.resource)
      expect(context.model).not_to be_nil
      expect(context.model).to eq(config.model)
    end

    context "initialize parents" do
      specify "parents is empty given no parent in config" do
        context = ActAsAdmin::Controller::Context.new(config, {
        :action=>:index, :parent_id=>"1234", :id=>"resource_id"})
        expect(context.parents).to be_empty
      end

      specify "single parents could be resolved by finding from the model" do
        config.parent :parent, :model=>Parent, :on=>:resources
        Parent.should_receive(:find).with("parent_id").and_return(parent)

        context = ActAsAdmin::Controller::Context.new(config, {:action=>:index, :parent_id=>"parent_id", :id=>"resource_id"})

        expect(context.parents.count).to eq(1)
        expect(context.parents.keys).to eq([parent])
        expect(context.parents[parent]).to eq(:on=>:resources, :resource_name=>:parent)
      end

      specify "nested parents could be resolved by finding from the parents chain in config" do
        dummies = mock("Dummy collection")
        config.parent :parent, :on=>:dummies, :model=>Parent
        config.parent :dummy, :on=>:resources, :model=>Dummy

        Parent.should_receive(:find).with("parent_id").and_return(parent)
        parent.should_receive(:dummies).and_return(dummies)
        dummies.should_receive(:find).with("dummy_id").and_return(dummy)

        context = ActAsAdmin::Controller::Context.new(config, {:action=>:index,
                                                               :parent_id=>"parent_id", :dummy_id=>"dummy_id", :id=>"resource_id"})


        expect(context.parents.count).to eq(2)
        expect(context.parents.keys).to eq([parent, dummy])
        expect(context.parents[parent]).to eq(:on=>:dummies, :resource_name=>:parent)
        expect(context.parents[dummy]).to eq(:on=>:resources, :resource_name=>:dummy)
      end

      specify "polymorphic parents could be resolved by matching param id values and parents name" do
        config.parent :polymorphic, :parents=>{
          :dummy => {:on=>:resources, :model=>Dummy},
          :parent => {:on=>:resources, :model=>Parent}
        }

        Parent.should_receive(:find).with("parent_id").and_return(parent)
        Dummy.should_not_receive(:find)

        context = ActAsAdmin::Controller::Context.new(config, {:action=>:index, :parent_id=>"parent_id", :id=>"resource_id"})

        expect(context.parents.count).to eq(1)
        expect(context.parents.keys).to eq([parent])
        expect(context.parents[parent]).to eq(:on=>:resources, :resource_name=>:parent)
      end
    end

  end

end
