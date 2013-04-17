require "spec_helper"

describe Admin::Builder::Query do

  it "should have default scope" do
    subject.scope(:expired){|criteria| criteria.where(:expired=>true)}
    subject.scope(:active, :default=>true){|criteria| criteria.where(:active=>true)}

    subject.default_scope.should_not be_nil
    subject.default_scope[0].should == :active
    subject.default_scope[1].should == subject.scopes[:active]
  end

  it "should have default order" do
    subject.order(:created_at, :dir=>"desc")
    subject.order(:start_date, :dir=>"asc", :default=>true)

    subject.default_order.should_not be_nil
    subject.default_order[0].should == :start_date
    subject.default_order[1].should == subject.orders[:start_date]
  end
  
end