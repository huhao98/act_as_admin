require 'spec_helper'

describe ActAsAdmin::Builder::ResourceConfig do

  let(:resource_config){ActAsAdmin::Builder::ResourceConfig.new(:test)}

  describe "path" do
    # stories resource example
    # parent_path(:farmers)
    # parent_path(:farmers).next(:product)
    #
    # photoes resource example
    #
    # parent_path(:product){|product_id| Product.find(:id=>product_id)}
    #  .to(:album){|album_id, product| product.albums.find(:album_id)}
    #  .to(:photo){|id, album| album.photoes.find(id)}

    # /products/:product_id/albums/:album_id/photoes/:id,
    # Product.find(:id=>product_id).albums.find(:id=>album_id).photoes.find(:id=>id)
    #
    # parent_path(:story).next(:album) /stories/:story_id/albums/:album_id/photoes/:id
    # parent_path(:farmer).next(:album) /farmers/:farmer_id/albums/:album_id/photoes/:id
    it "should create resource path" do
      resource_config.path(:dummy)
      resource_config.path(:dummy).to(:products)

      expect(resource_config.paths.size).to eq(2)
    end
  end

  describe "path_for" do
    before :each do
      resource_config.path(:dummy)
      resource_config.path(:dummy).to(:products)
    end

    it "should find the first matching path" do
      params = {:id=>"product_id", :dummy_id=>"dummy_id"}.with_indifferent_access
      expect(resource_config.path_for params).to eq(resource_config.paths[1])
    end

    it "should find the root path given no parent ids in the params" do
      params = {:id=>"product_id"}.with_indifferent_access
      expect(resource_config.path_for params).to eq(resource_config.paths[0])
    end
  end

  describe "field" do
    it "should set formattable attributes" do
      resource_config.field(:name).show
      expect(resource_config.formatters[:name].count).to eq(1)
    end

    it "should find field formatter proc" do
      resource_config.field(:name).show{}
      expect(resource_config.formatters[:name].first.as).to be_a(Proc)
    end

    it "should find field formatter" do
      resource_config.field(:name).show(:as=>:date_time)
      expect(resource_config.formatters[:name].first.as).to eq(:date_time)
    end

    it "should set field assigner proc" do
      resource_config.field(:name).assign{"user's name"}
      expect(resource_config.assigners.count).to eq(1)
    end

    context "nested fields" do
      it "should create nested fields" do
        resource_config.field(:name).show
        resource_config.field(:address) do
          field(:city).show
        end.show

        data = mock("data", :city=>"city")
        expect(resource_config.find_formatters(:fields=>[:"address.city"])).not_to be_nil
      end
    end
  end

  describe "scope" do
    it "should created nested resource" do
      resource_config.field(:name).show
      resource_config.scope(:order_item) do
        field(:quantiy).show
      end

      expect(resource_config.formatters.keys).to eq([:name])
      expect(resource_config.scopes[:order_item]).to be_a(ActAsAdmin::Builder::ResourceConfig)
    end
  end

  describe "scope_names" do
    it "should return all the scope names" do
      resource_config.scope(:order_item) do
        field(:quantiy).show
      end
      resource_config.scope(:address) do
        field(:city).show
      end

      expect(resource_config.scope_names).to eq([:order_item, :address])
    end
  end

  specify "should assign values to data fields" do
    data = {:name=>"blank"}.to_ostruct
    resource_config.field(:name).assign{"test"}
    resource_config.assign_fields(data)
    expect(data.name).to eq("test")
  end

  specify "should find formatters by actions and formats" do
    resource_config.field(:name).show(:as=>:default).show(:format=>:csv, :as=>:csv)

    formatter = resource_config.find_formatters.first
    expect(formatter.as).to eq(:default)

    formatter = resource_config.find_formatters(:format=>:csv).first
    expect(formatter.as).to eq(:csv)

    formatter = resource_config.find_formatters(:action=>:index, :format=>:csv).first
    expect(formatter.as).to eq(:csv)
  end

end
