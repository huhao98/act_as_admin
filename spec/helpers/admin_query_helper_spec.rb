require 'spec_helper'

describe AdminQueryHelper do  

  pending "applied_dir" do
    it "should be nil given no applied order in the query" do
      mongo_query.applied_orders = {}
      expect(mongo_query.applied_dir :created_at).to be_nil
    end

    it "should be the direction of the applied order in the query given the field's order is applied" do
      mongo_query.applied_orders = {:created_at => "desc"}
      expect(mongo_query.applied_dir :created_at).to eq("asc")
    end
  end
  
end