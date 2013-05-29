require 'spec_helper'

describe ::ActAsAdmin::Helpers::PathHelper do

  def setup_helper &block
    config = ActAsAdmin::Config.new(:model=>::Dummy, :resource_name=>"dummy")
    config.resource{path(:dummies)}
    context = ActAsAdmin::Controller::Context.new(config, {:action=>:some_action})
    context.stub!(:resource_components=>ActAsAdmin::Builder::ResourceComponents.new(yield()))

    helper = mock(ActAsAdmin::Helpers::PathHelper)
    helper.extend ActAsAdmin::Helpers::PathHelper
    helper.instance_variable_set("@context", context)
    return helper
  end

 
  describe 'single resource path' do
    let (:helper) do
      setup_helper do
        {:dummy => {:collection=>"dummy_collection", :resource=>dummy}}
      end
    end

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
    let (:helper) do
      setup_helper do {
        :dummy => {:collection=>"dummy_collection", :resource=>"dummy"},
        :album => {:collection=>"album_collection", :resource=>"album"}
      }
      end
    end

    specify "should create new nested resource path" do
      helper.should_receive(:new_dummy_album_path).with("dummy")
      helper.new_resource_path
    end

    specify "should create edit nested resource path" do
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

    specify "should create nested redirect to resources path" do
      helper.should_receive(:dummy_albums_path).with("dummy")
      helper.redirect_to_resources_path
    end

    specify "should create nested redirect to parent path given exclude :index option is set" do
      helper = setup_helper do { 
        :dummy => {:collection=>"dummy_collection", :resource=>"dummy"},
        :album => {:collection=>"album_collection", :resource=>"album",  :exclude=>[:index]} 
      }
      end

      helper.should_receive(:dummy_path).with("dummy")
      helper.redirect_to_resources_path
    end

  end

end
