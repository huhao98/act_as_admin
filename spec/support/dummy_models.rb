class Dummy; extend ActiveModel::Naming; attr_accessor :name; end

class Parent; extend ActiveModel::Naming; attr_accessor :title; end

module DummyModels
  extend ActiveSupport::Concern

  included do

    let(:dummy) do
      dummy = Dummy.new
      dummy.name = "A Dummy"
      dummy
    end

    let(:dummy_collection){mock("Dummies", :find=>dummy)}

    let(:parent) do
      parent = ::Parent.new;
      parent.title = "A Parent"
      parent.stub(:dummies=>dummy_collection)
      parent
    end

    let(:parent_collection){mock("Parents", :find=>parent)}

    before :each do
      Dummy.stub(:all=>dummy_collection, :new=>dummy)
      Parent.stub(:all=>parent_collection)
    end

  end

end
