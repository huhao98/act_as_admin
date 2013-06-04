require "spec_helper"

describe ActAsAdmin::Builder::Dsl do
  before :each do
    class DummyDsl
      include ActAsAdmin::Builder::Dsl
    end
  end

  after :each do
    Object.send(:remove_const, :DummyDsl)
  end

  describe "field" do

    it "should return empty Hash given no value is appended" do
      DummyDsl.field :names, :key=>true

      test = DummyDsl.new

      test.names.should be_a(Hash)
      test.names.should be_empty
    end

    it "should store values in a Hash" do
      DummyDsl.field :names, :key=>true

      test = DummyDsl.new
      test.name :b, :editable=>true

      test.names.should be_a(Hash)
      test.names.keys.should == [:b]
      test.names[:b].should == {:editable=>true}
    end

    it "should return option as an empty Hash given no option is set on the key" do
      DummyDsl.field :names, :key=>true, :proc=>:url
      test = DummyDsl.new

      test.name(:a)

      test.names.size.should == 1
      test.names[:a].should be_a(Hash)
      test.names[:a].should be_empty
    end

    it "should take a block parameter and store in the hash given proc option is given" do
      DummyDsl.field :names, :key=>true, :proc=>:url
      test = DummyDsl.new

      test.name(:a){|b|}

      test.names.size.should == 1
      value = test.names[:a]
      value[:url].should be_a(Proc)
    end

  end
end
