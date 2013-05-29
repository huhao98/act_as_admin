require 'spec_helper'

describe ActAsAdmin::Builder::ResourceComponents do
  def setup components
    return ActAsAdmin::Builder::ResourceComponents.new(components) 
  end

  let(:resource_components){
    setup(
      :dummy => {:collection=>"dummy_collection", :resource=>"dummy"},
      :album => {:collection=>"album_collection", :resource=>"album"}
    )
  }

  it 'should return resource component' do
    expect(resource_components.resource).to eq("album")
  end

  it "should return resource collection" do
    expect(resource_components.collection).to eq("album_collection")
  end

  describe "resources" do
    it "should yield resource name and resource opts" do
      resource_components = setup(
        :dummies => {:collection=>"dummy_collection", :resource=>dummy, :title=>:name}
      )
      expect{|b| resource_components.resources &b}.to yield_with_args({}, :dummy, {:title=>:name})
    end

    it "should yield parents and resource name" do
      resource_components = setup(
        :dummies => {:collection=>"dummy_collection", :resource=>dummy, :title=>:name},
        :orders => {:collection=>"order_collection", :resource=>"order", :title=>:id, :exclude=>[:index]}
      )

      expect{|b| resource_components.resources &b}.to yield_with_args(
        {:dummy=>dummy}, :order, {:title=>:id, :exclude=>[:index]}
      )
    end
  end

end
