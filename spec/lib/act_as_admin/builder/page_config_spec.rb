require 'spec_helper'

describe ActAsAdmin::Builder::PageConfig do
  let(:page){ActAsAdmin::Builder::PageConfig.new}

  specify "should exclude named configuration when clone" do
    page.action(:add, :url=>"add_url")
    page.action(:delete, :url=>"delete_url")

    new_page = ActAsAdmin::Builder::PageConfig.clone(page, :exclude=>{:actions=>:add})

    expect(new_page.actions[:add]).to be_nil
    expect(new_page.actions[:delete]).to eq(:url=>"delete_url")
  end
  

  specify "actions has url option" do
    url_proc = Proc.new{}
    page.action(:add, &url_proc)
    page.action(:delete, :url=>"delete_url")

    expect(page.actions[:add]).to eq(:url=>url_proc)
    expect(page.actions[:delete]).to eq(:url=>"delete_url")
  end

  specify "headers has text option" do
    text_proc = Proc.new{}
    page.header(:major, &text_proc)
    page.header(:minor, :text=>"title")

    expect(page.headers[:major]).to eq(:text=>text_proc)
    expect(page.headers[:minor]).to eq(:text=>"title")
  end

  describe "query" do
    it "should create default query config given name is not provided" do
      page.queries.should be_empty
      page.query :as=>:orders

      expect(page.queries[:default].opts).to eq(:as=>:orders)
    end

    it "should inherit from query config with same name" do
      page.query(:name, :as=>:orders) do
        query_path {"resources_url"}
        query_from {"Dummy.all"}
        page 20
      end

      page.query :name do
        page 10
      end

      query_config = page.queries[:name]
      expect(query_config.as).to eq(:orders)
      expect(query_config.per_page).to eq(10)
    end
  end

  describe "form" do
    it "should create default form config given name is not provided" do
      page.forms.should be_empty
      page.form

      expect(page.forms[:default]).not_to be_nil
    end

    it "should inherit from form config with same name" do
      page.form(:new, :fields=>[:name], :as=>:orders) do
        submit(:create, :method=>:put){resource_url}
      end

      page.form(:new, :as=>:book, :method=>:post)

      expect(page.forms[:new].fields).to eq([:name])
      expect(page.forms[:new].as).to eq(:book)
      expect(page.forms[:new].method).to eq(:post)
      expect(page.forms[:new].url).to be_a(Proc)
    end
  end


  describe "list" do
    it "should accetp variable arguments" do
      page.list :name
      expect(page.lists[:name]).not_to be_nil

      page.list :fields=>[:name, :date]
      expect(page.lists[:default].opts).to eq(:fields=>[:name, :date])

      page.list :name, :fields=>[:name, :date]
      expect(page.lists[:name].opts).to eq(:fields=>[:name, :date])
    end

    it "should create default list config given name is not provided" do
      page.lists.should be_empty
      page.list 

      expect(page.lists[:default]).not_to be_nil
    end

    it "should inherit from list config with same name" do 
      page.list :name, :fields=>[:names] do
        action :new, :url=>"new_url"
      end

      page.list :name do
        action :edit, :url=>"edit_url"
      end

      list_config = page.lists[:name]
      expect(list_config.opts[:fields]).to eq([:names])
      expect(list_config.actions.size).to eq(2)
      expect(list_config.actions[:new]).to eq(:url=>"new_url")
      expect(list_config.actions[:edit]).to eq(:url=>"edit_url")
    end

  end

  describe "query" do
    it "should accetp variable arguments" do
      page.query { query_from {"Root Query"} }
      expect(page.queries[:default]).to be_a(ActAsAdmin::Builder::QueryConfig)
    end
  end



end
