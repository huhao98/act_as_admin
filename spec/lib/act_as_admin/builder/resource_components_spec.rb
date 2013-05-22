require 'spec_helper'

describe ActAsAdmin::Builder::ResourceComponents do
  let(:resource_components){
    components = {
      :dummy => {:collection=>"dummy_collection", :resource=>"dummy"},
      :album => {:collection=>"album_collection", :resource=>"album"}
    }
    ActAsAdmin::Builder::ResourceComponents.new(components)
  }

  it 'should return resource component' do
    expect(resource_components.resource).to eq("album")
  end

  it "should return resource collection" do
    expect(resource_components.collection).to eq("album_collection")
  end

  describe "resource_path" do
    context "for single component" do
      let(:resource_components){
        components = {:dummy => {:collection=>"dummy_collection", :resource=>"dummy"}}
        ActAsAdmin::Builder::ResourceComponents.new(components)
      }

      specify do
        expect{|b| resource_components.resource_path(resource: "a dummy", &b)}.to yield_with_args("dummy_path", "a dummy")
      end

      specify do
        expect{|b| resource_components.resource_path(action: "new", &b)}.to yield_with_args("new_dummy_path")
      end
     
    end

    context "for multiple components" do
      specify do
        expect{|b| resource_components.resource_path(resource: "an album", &b)}.to yield_with_args("dummy_album_path", "dummy", "an album")
      end

      specify do
        expect{|b| resource_components.resource_path(action: "new", &b)}.to yield_with_args("new_dummy_album_path", "dummy")
      end
    end

  end

  describe "resources_path" do
    context "for single component" do
      let(:resource_components){
        components = {:dummies => {:collection=>"dummy_collection", :resource=>"dummy"}}
        ActAsAdmin::Builder::ResourceComponents.new(components)
      }

      specify do
        expect{|b| resource_components.resources_path &b}.to yield_with_args("dummies_path")
      end

      specify do
        expect{|b| resource_components.resources_path(action: "view", &b)}.to yield_with_args("view_dummies_path")
      end

      specify do
        components = {:dummies => {:collection=>"dummy_collection", :resource=>"dummy", :exclude=>[:index]}}
        resource_components = ActAsAdmin::Builder::ResourceComponents.new(components) 
        expect{|b| resource_components.resources_path(&b)}.to yield_with_args("dummies_path")
      end
    end

    context "for multiple components" do
      specify do
        expect{|b| resource_components.resources_path &b}.to yield_with_args("dummy_albums_path", "dummy")
      end
      specify do
        expect{|b| resource_components.resources_path(action: "view", &b)}.to yield_with_args("view_dummy_albums_path", "dummy")
      end

      specify do
        components = {
          :dummies => {:collection=>"dummy_collection", :resource=>"dummy"},
          :albums => {:collection=>"album_collection", :resource=>"album", :exclude=>[:index]}
        }
        resource_components = ActAsAdmin::Builder::ResourceComponents.new(components) 
        expect{|b| resource_components.resources_path(&b)}.to yield_with_args("dummy_path", "dummy")
      end
    end

  end

end
