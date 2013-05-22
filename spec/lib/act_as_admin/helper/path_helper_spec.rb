require 'spec_helper'

describe ::ActAsAdmin::Helpers::PathHelper do
  setup_context

  let (:helper) do
    helper = mock(ActAsAdmin::Helpers::PathHelper)
    helper.extend ActAsAdmin::Helpers::PathHelper
    helper.instance_variable_set("@context", context)
    helper
  end

  before :each do
    dummy_collection = mock("Dummy collection", :find=>dummy)
    Dummy.stub(:all=>dummy_collection)
  end

  describe 'single resource path' do
    specify('should create new_resource_path') do
      helper.should_receive(:new_dummy_path).with(no_args)
      helper.new_resource_path
    end

    specify('should create edit_resource_path') do
      helper.should_receive(:edit_dummy_path).with(dummy)
      helper.edit_resource_path dummy
    end

    specify('should create resource_path') do
      helper.should_receive(:dummy_path).with(dummy,{:q=>"search"})
      helper.resource_path dummy, :q=>"search"
    end

    specify('should create resources_path') do
      helper.should_receive(:dummies_path).with({:q=>"search"})
      helper.resources_path :q=>"search"
    end

  end

  describe 'nested resource' do
    let(:resource_components){
      components = {
        :dummy => {:collection=>"dummy_collection", :resource=>"dummy"},
        :album => {:collection=>"album_collection", :resource=>"album"}
      }
      ActAsAdmin::Builder::ResourceComponents.new(components)
    }


    before :each do
      context.stub(:resource_components=>resource_components)
    end

    specify do
      helper.should_receive(:new_dummy_album_path).with("dummy")
      helper.new_resource_path
    end

    specify do
      helper.should_receive(:edit_dummy_album_path).with("dummy", "an album")
      helper.edit_resource_path("an album")
    end

    specify('should create nested resource path') do
      helper.should_receive(:dummy_album_path).with("dummy", "an album")
      helper.resource_path "an album"
    end

    specify('should create nested resources path') do
      helper.should_receive(:dummy_albums_path).with("dummy")
      helper.resources_path
    end

    specify('should create nested resources path with params') do
      helper.should_receive(:dummy_albums_path).with("dummy", :q=>"search")
      helper.resources_path :q=>"search"
    end

  end

end
