class Dummy; extend ActiveModel::Naming; attr_accessor :name; end

class Parent; extend ActiveModel::Naming; attr_accessor :title; end

module DummyModels
  extend ActiveSupport::Concern

  included do
    let(:dummy){::Dummy.new}
    let(:parent){parent = ::Parent.new; parent.stub(:title=>"A Parent"); parent}
  end

  module ClassMethods
    def setup_context
      let(:config){ActAsAdmin::Config.new(:model=>::Dummy, :resource_name=>"dummy")}
      let(:context){ActAsAdmin::Controller::Context.new(config, {:action=>:some_action})}
    end

    def setup_config
      let(:config){ActAsAdmin::Config.new(:model=>::Dummy, :resource_name=>"dummy")}
    end
  end

end
