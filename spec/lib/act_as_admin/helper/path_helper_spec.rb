require 'spec_helper'

describe ::ActAsAdmin::Helpers::PathHelper do 

  let (:helper) do 
    helper= PathHelper.new; 
    helper.instance_variable_set("@model", Dummy)
    helper.instance_variable_set("@parents",{})
    helper
  end

  before :each do
    class Parent;extend ActiveModel::Naming; end
    class Dummy; extend ActiveModel::Naming; end
    class PathHelper; include ::ActAsAdmin::Helpers::PathHelper; end
  end

  after :each do
    Object.send(:remove_const, :Parent)
    Object.send(:remove_const, :Dummy)
    Object.send(:remove_const, :PathHelper)
  end

  specify('should create new_resource_path') do
    helper.should_receive(:new_dummy_path).with({})
    helper.new_resource_path
  end

  specify('should create edit_resource_path') do
    dummy = Dummy.new
    helper.should_receive(:edit_dummy_path).with(dummy,{})
    helper.edit_resource_path dummy
  end

  specify('should create resource_path') do
    dummy = Dummy.new
    helper.should_receive(:dummy_path).with(dummy,{})
    helper.resource_path dummy
  end

  specify('should create resources_path') do
    helper.should_receive(:dummies_path).with({})
    helper.resources_path
  end

  describe 'to_resource_path' do
    it "should return the url with action given :action option is presented" do
      helper.should_receive(:new_dummy_path).with({})
      helper.to_resource_path :action=>:new, :resource=>:dummy
    end

    it "should contstruct url using :resource option" do
      helper.should_receive(:dummies_path).with({})
      helper.to_resource_path :resource=>:dummies
    end

    it "should include parents in the url" do      
      parent = Parent.new
      helper.instance_variable_set("@parents", {parent => {:on => :dummies}})
      helper.should_receive(:new_parent_dummies_path).with(parent, {})
      helper.to_resource_path :action=>:new, :resource=>:dummies
    end

    it "should invoke path helper with arguments given :args options is presented" do
      dummy = Dummy.new
      helper.should_receive(:dummy_path).with(dummy,{})
      helper.to_resource_path :resource=>:dummy, :args=>[dummy]
    end

    it "should invoke path helper with request parameters given :params option is presented" do
      helper.should_receive(:dummy_path).with({type: "test"})
      helper.to_resource_path :resource=>:dummy, :params=>{type: "test"}
    end

    it "should use the parents arguments to generate path" do
      dummy = Dummy.new
      parent = Parent.new
      helper.should_receive(:parent_dummy_path).with(parent, dummy, {})
      helper.to_resource_path({:singular=>true, :resource=>:dummy, :args=>[dummy]}, [parent])
    end
  end

end
