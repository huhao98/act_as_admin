require "spec_helper"


describe ActAsAdmin::Builder::Dsl do

  before :each do
    class Dummy
      include ActAsAdmin::Builder::Dsl
    end
  end

  after :each do
    Object.send(:remove_const, :Dummy)
  end

  describe "field" do
    context "without key" do
      it "should return empty Array given no values is appended" do
        Dummy.field :names

        test = Dummy.new

        test.names.should be_an(Array)
        test.names.should be_empty
      end

      it "should store values in an Array" do
        Dummy.field :names
        parent = Dummy.new
        test = Dummy.new(parent)

        parent.name "a"
        test.name "b"

        parent.names.should == ["a"]
        test.names.should == ["b"]
      end

      it "should inhert values from parent given inhert option is true" do
        Dummy.field :names, :inherit=>true

        parent = Dummy.new
        test = Dummy.new(parent)

        parent.name "a"
        test.name "b"

        test.names.should == ["a", "b"]
      end

      it "should not define dsl write method given without_writer option is true" do
        Dummy.field :names, :without_writer=>true
        test = Dummy.new
        test.respond_to?(:name).should be_false
      end
    end

    context "with key" do
      it "should return empty Hash given no value is appended" do
        Dummy.field :names, :key=>true

        test = Dummy.new

        test.names.should be_a(Hash)
        test.names.should be_empty
      end

      it "should store values in a Hash" do
        Dummy.field :names, :key=>true

        test = Dummy.new
        test.name :b, :editable=>true

        test.names.should be_a(Hash)
        test.names.keys.should == [:b]
        test.names[:b].should == {:editable=>true}
      end

      it "should not inherit values from parent" do
        Dummy.field :names, :key=>true

        parent = Dummy.new
        parent.name :a, :editable=>false

        test = Dummy.new
        test.name :b, :editable=>true

        test.names.keys.include?(:a).should be_false
      end

      it "should inhert values from parent given inherit option is true" do
        Dummy.field :names, :key=>true, :inherit=>true

        parent = Dummy.new
        test = Dummy.new(parent)

        parent.name :a, :editable=>false
        test.name :b, :editable=>true

        test.names.keys.should == [:a, :b]
        test.names[:a].should == {:editable=>false}
        test.names[:b].should == {:editable=>true}
      end

      it "should return option as an empty Hash given no option is set on the key" do
        Dummy.field :names, :key=>true, :proc=>:url
        test = Dummy.new

        test.name(:a)

        test.names.size.should == 1
        test.names[:a].should be_a(Hash)
        test.names[:a].should be_empty
      end

      it "should take a block parameter and store in the hash given proc option is given" do
        Dummy.field :names, :key=>true, :proc=>:url
        test = Dummy.new

        test.name(:a){|b|}

        test.names.size.should == 1
        value = test.names[:a]
        value[:url].should be_a(Proc)
      end

    end
  end
end