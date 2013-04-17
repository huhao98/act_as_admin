require 'spec_helper'

describe ActAsAdmin::Helpers::NavHelper do

  let (:helper) do 
    helper = NavHelper.new; 
    helper.instance_variable_set("@model", Orange)
    helper.instance_variable_set("@parents",{})
    helper.stub(:url_for => {}, :params => {})
    helper
  end

  before :each do    
    class Apple; extend ActiveModel::Naming; end
    class Orange;extend ActiveModel::Naming; end
    class NavHelper; include ::ActAsAdmin::Helpers::NavHelper; include ::ActAsAdmin::Helpers::PathHelper; end
  end

  after :each do
    Object.send(:remove_const, :Apple)
    Object.send(:remove_const, :Orange)
    Object.send(:remove_const, :NavHelper)
  end

  it "should render a simple nav item by title and url" do
    Rails.configuration.nav.stub!(:nav_items).and_return([{:title=>"Title", :url=>"/"}])    

    helper.should_receive(:link_to).with("Title", "/").and_return("simple_link")
    helper.should_receive(:content_tag).with(:li, "simple_link", nil).and_return("li_with_link")
    helper.should_receive(:concat).with("li_with_link")

    helper.admin_nav_items
  end

  it "should render an active simple nav item given the url matchs current controller and action" do
    Rails.configuration.nav.stub!(:nav_items).and_return([{:title=>"Title", :url=>"/oranges"}])
    helper.stub(:link_to=>"oranges_link", :concat=>"", :params=>{:controller=>"orange_controller", :action=>"index"})

    helper.should_receive(:url_for).with(:controller=>"orange_controller", :action=>"index").and_return("/oranges")
    helper.should_receive(:content_tag).with(:li, "oranges_link", :class=>:active)    
  
    helper.admin_nav_items
  end


  it "should render nav item for a model" do
    Rails.configuration.nav.stub!(:nav_items).and_return([{:model=>Apple}])
    helper.stub(:apples_path=>"apples_link")

    helper.should_receive(:nav_item) do |title, url, active|
      expect(title).to eq("Apple")
      expect(url).to eq("apples_link")
      expect(active).to be_false
      "apple_nav_item"
    end
    helper.should_receive(:concat).with("apple_nav_item")

    helper.admin_nav_items
  end

  it "should render active nav item for a modle which is assigned in the current context" do
    Rails.configuration.nav.stub!(:nav_items).and_return([{:model=>Apple}])
    helper.instance_variable_set("@model", Apple)
    helper.stub(:apples_path=>"apples_link", :concat=>"")

    helper.should_receive(:nav_item){|title, url, active| expect(active).to be_true}

    helper.admin_nav_items
  end

  it "should render nav item for group of models"  do
    Rails.configuration.nav.stub!(:nav_items).and_return([{:title=>"Group", :models=>[Apple, Orange]}])

    helper.should_receive(:bootstrap_dropdown_menu) do |title, cls, &block|
      expect(title).to eq("Group")
      expect(cls).to eq(:active)
      block.call
      "dropdown_menu"
    end

    helper.should_receive(:apples_path).and_return("apples_path")
    helper.should_receive(:nav_item).with("Apple", "apples_path", false).ordered.and_return("apple_nav_item")    
    helper.should_receive(:concat).with("apple_nav_item").ordered

    helper.should_receive(:oranges_path).and_return("oranges_path")
    helper.should_receive(:nav_item).with("Orange", "oranges_path", true).ordered.and_return("orange_nav_item")    
    helper.should_receive(:concat).with("orange_nav_item").ordered

    helper.should_receive(:concat).with("dropdown_menu").ordered

    helper.admin_nav_items
  end

end