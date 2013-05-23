require 'spec_helper'

describe ActAsAdmin::Controller::MongoQueryExecutor do

  let(:query){ActAsAdmin::Builder::QueryConfig.new}
  let(:from) do
    criteria = mock(:criteria, :paginate=>"results")
    criteria.stub(:where=>criteria, :order_by=>criteria)
    criteria
  end
  let(:query_executor){ActAsAdmin::Controller::MongoQueryExecutor.new(from, query)}

  describe "order" do
    it "should order results by request parameters" do
      query.order :created_at, :dir=>"desc"
      from.should_receive(:order_by).with([[:created_at, "asc"]])

      query_executor.order("created_at"=>"asc")
      expect(query_executor.query_params[:o]).to eq(:created_at=>"asc")
    end

    it "should order results by default order" do
      query.order :start_date, :dir=>"asc"
      query.order :created_at, :dir=>"desc", :default=>true
      from.should_receive(:order_by).with([[:created_at, "desc"]])

      query_executor.order
      expect(query_executor.query_params[:o]).to eq(:created_at=>"desc")
    end

    it "should not order results given there are no default order and order request parameter" do
      from.should_not_receive(:order_by)
      query_executor.order
      expect(query_executor.query_params[:o]).to be_nil
    end
  end

  describe "filter" do
    it "can execute multiple filters" do
      query.filter(:name){|c,v| c.any_of(:name=>/#{v}/)}
      query.filter(:email){|c,v| c.any_of(:email=>/#{v}/)}

      from.should_receive(:any_of).with(:name=>/name text/).ordered.and_return(from)
      from.should_receive(:any_of).with(:email=>/email text/).ordered.and_return(from)
      query_executor.filter(:name=>"name text", :email=>"email text")
      expect(query_executor.query_params[:f]).to eq(:name=>"name text", :email=>"email text")
    end

    it "should execute default filter given filter condition is not specified in the query" do
      query.filter(:name)

      from.should_receive(:any_of).with(:name=>/name/i).and_return(from)
      query_executor.filter(:name=>"name")
      expect(query_executor.query_params[:f]).to eq(:name=>"name")
    end

    it "should not execute filter not defined in the query" do
      query.filter(:name){|c,v| c.any_of(:name=>/#{v}/)}

      from.should_receive(:any_of).with(:name=>/name text/).ordered
      query_executor.filter(:name=>"name text", :email=>"email text")
      expect(query_executor.query_params[:f]).to eq(:name=>"name text")
    end

    it "should not filter given filter params is empty" do
      query.filter(:name){|c,v| c.any_of(:name=>/#{v}/)}

      from.should_not_receive(:any_of)
      query_executor.filter()
      expect(query_executor.query_params[:f]).to be_nil
    end

    it "can filter by arbitray value" do
      query.filter(:name){|c, v| c.where(:name=>/#{v}/)}

      from.should_receive(:where).with(:name=>/test/)
      query_executor.filter(:name=>"test")
      expect(query_executor.query_params[:f]).to eq(:name=>"test")
    end

    it "can filter by value from selection" do
      query.filter(:cover, :values=>["soft", "hard"]){|c, v| c.any_in(:cover=>v)}

      from.should_receive(:any_in).with(:cover=>"soft")
      query_executor.filter(:cover=>"soft")
      expect(query_executor.query_params[:f]).to eq(:cover=>"soft")
    end

    it "can filter by range" do
      query.filter(:price, :type=>:ranges){|c, v| c.where(:price.gt=>v[0], :price.lt=>v[1])}

      from.should_receive(:where).with(:price.gt=>"20", :price.lt=>"30")
      query_executor.filter(:price=>["20","30"])
      expect(query_executor.query_params[:f]).to eq(:price=>["20","30"])
    end

    it "should update query_meta_data" do
      query.filter(:cover, :type=>:scope)

      from.should_receive(:distinct).with(:cover).and_return(["soft", "hard"])
      from.should_receive(:where).with(:cover=>"soft").and_return(from)
      query_executor.filter(:cover=>"soft")
      expect(query_executor.query_params[:f]).to eq(:cover=>"soft")
      expect(query_executor.query_meta_data).to eq(:cover=>{:values=>["soft", "hard"]})
    end

  end

  

end
