require 'spec_helper'

describe ActAsAdmin::Config do 

  let(:config){ActAsAdmin::Config.new}

  it "default page should be a page for default action" do
    config.default_page.should_not be_nil
    config.default_page.should be_a(ActAsAdmin::Builder::Page)
    config.default_page.should eq(config.pages[:default])
  end

  it "default query should be a query for index action" do
    config.default_query.should_not be_nil
    config.default_query.should be_a(ActAsAdmin::Builder::Query)
    config.default_query.should eq(config.queries[:index])
  end

  it "default form should be a from for both new and edit action" do
    config.default_form.should_not be_nil
    config.default_form.should be_a(ActAsAdmin::Builder::Form)
    config.default_form.should eq(config.forms[:new])
    config.default_form.should eq(config.forms[:edit])
  end

  describe "page" do
    it "should yield default page to the block" do
      expect{|b| config.page &b}.to yield_with_args(config.default_page)
    end

    it "can yeild a new page for an action" do
      expect{|b| config.page(:index, &b)}.to yield_with_args(ActAsAdmin::Builder::Page)

      expect(config.pages.size).to eq(2)
      expect(config.pages[:default]).to eq(config.default_page)
      expect(config.pages[:index]).to be_a(ActAsAdmin::Builder::Page)
    end

  end

  describe "form" do
    it "should yield default form to the block" do
      expect{|b| config.form &b}.to yield_with_args(config.default_form)
    end

    it "should yield a new form for action other than :edit and :new" do
      config.form :other do |form|
        form.should == config.forms[:other]
      end

      config.forms[:other].should be_a(ActAsAdmin::Builder::Form)
      config.forms[:other].should_not eq(config.forms[:new])
    end

    it "should yield a new form for action within the block of page with action" do
      config.page :other do
        expect{|b| config.form &b}.to yield_with_args(config.forms[:other])
      end

      config.forms[:other].should be_a(ActAsAdmin::Builder::Form)
      config.forms[:other].should_not eq(config.forms[:new])
    end
  end

  describe "query" do

    it "should yield default query to the block" do
      expect{|b| config.query &b}.to yield_with_args(config.default_query)
    end

    it "should yield a new query for none index action" do
      config.query :other do |query|
        query.should eq(config.queries[:other])
      end

      config.queries.count.should == 2
      config.queries[:other].should be_a(ActAsAdmin::Builder::Query)
      config.queries[:other].should_not eq(config.queries[:index])
    end

    it "should yield a new query for action within the block of page with action" do
      config.page :other do
        expect{|b| config.query &b}.to yield_with_args(config.queries[:other])
      end

      config.queries[:other].should be_a(ActAsAdmin::Builder::Query)
      config.queries[:other].should_not eq(config.forms[:index])
    end
  end

  describe "resource" do
    it "should delegate :resource_attr to resource object" do
      config.resource.should_receive(:field) do |key, opts, &block|
        expect(key).to eq(:user)
        expect(opts).to eq(:when=>:new)
        expect(block).to be_a(Proc)
      end

      config.field(:user, :when=>:new){current_user}
    end

    it "should delegate :query_from to resource object" do
      config.resource.should_receive(:query_from) do |&block|
        expect(block).to be_a(Proc)
      end
      config.query_from{current_user.books}
    end
  end

end