require "spec_helper"

describe ActAsAdmin::Builder::QueryConfig do  

  it "should have default order" do
    subject.order(:created_at, :dir=>"desc")
    subject.order(:start_date, :dir=>"asc", :default=>true)

    subject.default_order.should_not be_nil
    subject.default_order[0].should == :start_date
    subject.default_order[1].should == subject.orders[:start_date]
  end
  
end