require 'spec_helper'

describe ActAsAdmin::Builder::PageConfig do
  let(:page){ActAsAdmin::Builder::PageConfig.new}

  describe "list" do
    it "should accetp variable arguments" do
      page.list :name
      expect(page.lists[:name]).not_to be_nil

      page.list :fields=>[:name, :date]
      expect(page.lists[:default].opts).to eq(:fields=>[:name, :date])

      page.list :name, :fields=>[:name, :date]
      expect(page.lists[:name].opts).to eq(:fields=>[:name, :date])
    end
  end

  describe "query" do
    it "should accetp variable arguments" do
      page.query { query_from {"Root Query"} }
      expect(page.queries[:default]).to be_a(ActAsAdmin::Builder::QueryConfig)
    end
  end

  

end
