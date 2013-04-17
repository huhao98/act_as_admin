require 'spec_helper'

describe Admin::Controller::Query do

  describe "query" do

    let(:controller) do 
      controller = mock("Controller", :params=>{})
      controller.extend Admin::Controller::Query
      controller      
    end

    let(:criteria) do 
      criteria = mock(:criteria, :paginate=>"results")
      criteria.stub(:where=>criteria, :order_by=>criteria)
      criteria
    end

    let(:query){::Admin::Builder::Query.new}
    
    describe "root criteria" do
      specify "is taken from :from option given the query has no :on option" do
        criteria.should_receive(:paginate)
        controller.query_by query, :from=>criteria
      end

      specify "is taken from query's :on option given it is presented" do
        children_criteria = mock(:children_criteria)
        children_criteria.stub(:where=>criteria, :order_by=>criteria)

        children_criteria.should_receive(:paginate)
        criteria.should_not_receive(:paginate)

        controller.query_by(::Admin::Builder::Query.new :on=> -> {children_criteria})
      end

      it "should raise error when query has no :on option and :from option is not presented" do
        expect{controller.query_by query}.to raise_error
      end
    end

    context "order by" do
      it "should order results by request parameters" do
        query.order :created_at, :dir=>"desc"
        controller.stub!(:params => {:o=>{"created_at"=>"asc"}})
        
        criteria.should_receive(:order_by).with([[:created_at, "asc"]])
        controller.query_by query, :from=>criteria
        controller.instance_variable_get("@applied_orders").should == {:created_at=>"asc"}
      end

      it "should order results by default order" do
        query.order :start_date, :dir=>"asc"
        query.order :created_at, :dir=>"desc", :default=>true
        controller.stub(:params=>{})

        criteria.should_receive(:order_by).with([[:created_at, "desc"]])
        controller.query_by query, :from=>criteria
        controller.instance_variable_get("@applied_orders").should == {:created_at=>"desc"}
      end

      it "should not order results given there are no default order and order request parameter" do
        controller.stub!(:params => {})

        criteria.should_not_receive(:order_by)
        controller.query_by query, :from=>criteria
        controller.instance_variable_get("@applied_orders").should be_nil
      end
    end

    context "scope" do
      it "should query scope by request parameters" do
        query.scope(:active){|c| c.where(:active=>true)}
        controller.stub!(:params => {:s=>:active})

        criteria.should_receive(:where).with(:active=>true)
        controller.query_by query, :from=>criteria
        controller.instance_variable_get("@applied_scope").should == :active
      end

      it "should query scope by default scope" do
        query.scope(:active, :default=>true){|c| c.where(:active=>true)}
        controller.stub!(:params => {})

        criteria.should_receive(:where).with(:active=>true)
        controller.query_by query, :from=>criteria
        controller.instance_variable_get("@applied_scope").should == :active
      end

      it "should not query scope given there are no default scope and scope request parameter" do
        query.scope(:active){|c| c.where(:active=>true)}
        controller.stub!(:params => {})

        criteria.should_not_receive(:where)
        controller.query_by query, :from=>criteria
        controller.instance_variable_get("@applied_scope").should be_nil
      end
    end

  end

end
