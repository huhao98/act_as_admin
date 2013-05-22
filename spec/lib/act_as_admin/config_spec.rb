require 'spec_helper'

describe ActAsAdmin::Config do 

  let(:config){ActAsAdmin::Config.new}

  it "default page should be a page for default action" do
    config.default_page.should_not be_nil
    config.default_page.should be_a(ActAsAdmin::Builder::PageConfig)
    config.default_page.should eq(config.pages[:default])
  end
  
  it "should has a resource config" do
    config.resource_config.should_not be_nil
    config.resource_config.should be_a(ActAsAdmin::Builder::ResourceConfig)
  end

  describe "page" do
    it "should yield default page to the block" do
      expect{|b| config.page &b}.to yield_with_args(config.default_page)
    end

    it "can yeild a new page for an action" do
      expect{|b| config.page(:index, &b)}.to yield_with_args(ActAsAdmin::Builder::PageConfig)

      expect(config.pages.size).to eq(2)
      expect(config.pages[:default]).to eq(config.default_page)
      expect(config.pages[:index]).to be_a(ActAsAdmin::Builder::PageConfig)
    end

  end

  describe "resource" do
    
  end

end