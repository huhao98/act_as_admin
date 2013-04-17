require 'spec_helper'

describe AdminHelper do

  pending "action_dropdown" do

    it "should render a button given there a single action" do
      actions = {:action1 => {:url=>"path_to_action1"}}
      result = Nokogiri::HTML(action_dropdown actions)

      result.css("a").count.should == 1
      result.css("a[href='path_to_action1']").should_not be_empty
    end

    it "should render extra link options" do
      actions = {:action1 => {:url=>"path_to_action1"}}
      result = Nokogiri::HTML(action_dropdown actions, :class=>"btn")

      result.css("a[class='btn']").should_not be_empty
    end

    it "should render icon" do
       actions = {:action1 => {:url=>"path_to_action1", :icon=>"an-icon"}}
       result = Nokogiri::HTML(action_dropdown actions)

       result.css("a > i[class='an-icon']").should_not be_empty
    end

    it "should invoke url proc given url is a proc" do
      data = mock("Data")
      actions = {:action1 => {:data_item=>data, :url=>Proc.new{|b| self.should eq(AdminHelper); b.should eq(data); "data_path"}}}

      result = Nokogiri::HTML(action_dropdown actions)
      result.css("a[href='data_path']").should_not be_empty
    end

    it "should render a drop down menu given there are multiple actions" do
      actions = {
        :action1 => {:url=>"path_to_action1"},
        :action2 => {:url=>"path_to_action2"}
      }

      result = Nokogiri::HTML(action_dropdown actions)
      result.css(".btn-group > a").count.should == 1
      result.css(".btn-group > a[href='path_to_action1']").should_not be_empty

      result.css(".btn-group > ul > li > a").count.should == 1
      result.css(".btn-group > ul[class='dropdown-menu'] > li > a[href='path_to_action2']").should_not be_empty
    end

  end
  
end