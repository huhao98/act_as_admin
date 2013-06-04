require 'spec_helper'

describe ActAsAdmin::Builder::ResourcePath do

  let(:dummy){Dummy.new}
  let(:dummy_collection){dummy_collection = mock("Dummies", :find=>dummy)}
  let(:resource_path){ActAsAdmin::Builder::ResourcePath.new(:dummies)}

  before :each do 
    Dummy.stub(:all).and_return(dummy_collection)
  end

  it "should build root path" do
    resource_path = ActAsAdmin::Builder::ResourcePath.new(:dummies)

    expect(resource_path.paths[:dummies][:finder]).to be_a(Proc)
    expect(resource_path.paths[:dummies][:finder].call()).to eq(:collection=>dummy_collection)
    expect(resource_path.paths[:dummies][:finder].call("id")).to eq(:collection=>dummy_collection, :resource=>dummy)
  end

  it "should build root path with model option" do
    resource_path = ActAsAdmin::Builder::ResourcePath.new(:products, :model=>Dummy)

    expect(resource_path.paths[:products][:finder].call()).to eq(:collection=>dummy_collection)
  end

  it "should build root path with a proc" do
    echo = Proc.new{|id| id}
    resource_path = ActAsAdmin::Builder::ResourcePath.new(:products, &echo)

    expect(resource_path.paths[:products][:finder]).to eq(echo)
  end

  describe "to" do
    it "should build path component" do
      resource_path.to(:albums)
      expect(resource_path.paths.count).to eq(2)
      expect(resource_path.paths[:albums][:finder]).to be_a(Proc)

      album = mock("Album")
      albums_collection = mock("albums", :find=>album)
      dummy.stub(:albums => albums_collection)

      expect(resource_path.paths[:albums][:finder].call(nil, dummy)).to eq(:collection => albums_collection)
      expect(resource_path.paths[:albums][:finder].call("album_id", dummy)).to eq(:collection => albums_collection, :resource=>album)
    end

    it "should build path component with on option" do
      resource_path.to(:albums, :on=>:greate_albums)

      album = mock("Album")
      albums_collection = mock("albums", :find=>album)
      dummy.stub(:greate_albums => albums_collection)
      
      expect(resource_path.paths[:albums][:finder].call("album_id", dummy)).to eq(:collection => albums_collection, :resource=>album)
    end


    it "should build path component with a proc" do
      echo = Proc.new{|parent, id| "#{parent}.albums.find(:#{id})"}
      resource_path.to(:albums, &echo)

      expect(resource_path.paths[:albums][:finder]).to eq(echo)
    end

  end

  describe "match?" do
    it "should match params without ids" do
      params = {
        controller: "controller",
        action: "action"
      }.with_indifferent_access

      expect(ActAsAdmin::Builder::ResourcePath.new(:dummies).match?(params)).to be_true
    end

    it "should match params contain all the parent ids" do
      params = {
        dummy_id: "dummy_id",
        album_id: "album_id",
        id: "id",
        controller: "controller",
        action: "action"
      }.with_indifferent_access

      expect(ActAsAdmin::Builder::ResourcePath.new(:dummies).to(:albums).to(:photos).match?(params)).to be_true
    end

    it "should not match params contain part of the parent ids" do
      params = {
        dummy_id: "dummy_id",
        id: "id",
        controller: "controller",
        action: "action"
      }.with_indifferent_access

      expect(resource_path.to(:albums).to(:photos).match?(params)).to be_false
    end 

    it "should match params without parent ids" do
       params = {
        id: "id",
        controller: "controller",
        action: "action"
      }.with_indifferent_access

      expect(resource_path.match?(params)).to be_true
    end

    it "should not match params contain parent ids" do
      params = {
        dummy_id: "dummy_id",
        id: "id",
        controller: "controller",
        action: "action"
      }.with_indifferent_access

      expect(resource_path.match?(params)).to be_false
    end 
  end

  describe "resource_components" do
    let(:album){mock("Album")}
    let(:album_collection){mock("album_collection", :find=>album)}

    before (:each) do
      dummy.stub(:albums=>album_collection)
    end

    it "should have root resource collection" do
      resource_components = resource_path.resource_components({})

      expect(resource_components.components.size).to eq(1)
      expect(resource_components.components[:dummies]).to eq(:collection=>dummy_collection)
    end

    it "should have root resource" do
      resource_components = resource_path.resource_components({"id"=>"dummy_id"})

      expect(resource_components.components.size).to eq(1)
      expect(resource_components.components[:dummies]).to eq(:collection=>dummy_collection, :resource=>dummy)
    end

    it "should have components collection" do
      resource_path.to(:albums)
      resource_components = resource_path.resource_components({"dummy_id"=>"dummy_id"})

      expect(resource_components.components.size).to eq(2)
      expect(resource_components.components[:dummies]).to eq(:collection=>dummy_collection, :resource=>dummy)
      expect(resource_components.components[:albums]).to eq(:collection=>album_collection)
    end

    it "should have components" do
      resource_path.to(:albums)
      resource_components = resource_path.resource_components({"dummy_id"=>"dummy_id", "id"=>"album_id"})

      expect(resource_components.components.size).to eq(2)
      expect(resource_components.components[:dummies]).to eq(:collection=>dummy_collection, :resource=>dummy)
      expect(resource_components.components[:albums]).to eq(:collection=>album_collection, :resource=>album)
    end

    it "should have component options" do
      resource_path.to(:albums, :title=>:name, :exclude=>[:index], :other=>"other")

      resource_components = resource_path.resource_components({"dummy_id"=>"dummy_id", "id"=>"album_id"})
      expect(resource_components.components[:albums][:title]).to eq(:name)
      expect(resource_components.components[:albums][:exclude]).to eq([:index])
      expect(resource_components.components[:albums][:other]).to be_nil
    end

  end

end