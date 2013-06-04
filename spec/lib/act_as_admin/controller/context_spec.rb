require 'spec_helper'

describe ActAsAdmin::Controller::Context do

  def setup_context params={}
    format = mock(:format)
    format.stub(:html){|&block| block.call}
    
    config = ActAsAdmin::Config.new(:model=>::Dummy, :resource_name=>"dummy")
    config.resource{path(:dummies)}
    yield(config) if block_given?
    ActAsAdmin::Controller::Context.new(config, params)
  end

  describe "form" do
    specify "create form with input fields defined in the resource_config" do
      context = setup_context :action=>:new do |config|
        config.resource {field(:name).input(:type=>:text_area); field(:age).input(:type=>:text_field)}
        config.page(:new){form(:as=>:dummy){submit(:new, :method=>:post, :url=>"dummies_url")}}
      end

      form = context.form
      expect(form.action).to eq(:new)
      expect(form.as).to eq(:dummy)
      expect(form.method).to eq(:post)
      expect(form.url).to eq("dummies_url")
      expect(form.input_fields[:name]).to eq(:type=>:text_area)
      expect(form.input_fields[:age]).to eq(:type=>:text_field)
    end

    specify "only include input fields specified by the fields option when defining form" do
      context = setup_context :action=>:new do |config|
        config.resource {field(:name).input(:type=>:text_area); field(:age).input(:type=>:text_field)}
        config.page(:new){form(:as=>:dummy, :fields=>[:name]){submit(:new, :method=>:post, :url=>"dummies_url")}}
      end

      form = context.form
      expect(form.input_fields.size).to eq(1)
      expect(form.input_fields[:name]).to eq(:type=>:text_area)
    end
    
  end

  describe "list" do
    it "should create list with field formatters defined in the resource_config" do
      context = setup_context :action=>:index do |config|
        config.resource {field(:name).show; field(:age).show}
        config.page(:index) {list}
      end

      list = context.list
      expect(list.formatters[0].field).to eq(:name)
      expect(list.formatters[1].field).to eq(:age)
    end

    it "should only include required field formatters when fields option was provided when define list" do
      context = setup_context :action=>:index do |config|
        config.resource {field(:name).show; field(:age).show}
        config.page(:index) {list :fields=>[:age]}
      end

      list = context.list
      expect(list.formatters.size).to eq(1)
      expect(list.formatters[0].field).to eq(:age)
    end

    it "should only include field formatters for the action of context" do
      context = setup_context :action=>:index do |config|
        config.resource {field(:name).show(:action=>:show); field(:age).show}
        config.page(:index) {list}
      end

      list = context.list
      expect(list.formatters.size).to eq(1)
      expect(list.formatters[0].field).to eq(:age)
    end

    it "should inlcude scoped field formatters given scope is specified" do
      context = setup_context :action=>:index do |config|
        config.resource {
          field(:name).show
          scope(:nested) do
            field(:age).show
          end
        }
        config.page(:index) {
          list
          list :nested, :scope=>:nested
        }
      end

      list = context.list
      expect(list.formatters.size).to eq(1)
      expect(list.formatters[0].field).to eq(:name)

      list = context.list :nested
      expect(list.formatters.size).to eq(1)
      expect(list.formatters[0].field).to eq(:age)
    end

    it "should include actions defined in the page_config" do
      context = setup_context :action=>:index do |config|
        config.resource {field(:name)}
        config.page(:index) {
          list do
            action(:add){}
          end
        }
      end

      list = context.list
      expect(list.actions.size).to eq(1)
      expect(list.actions[:add]).not_to be_nil
    end
  end

  describe "lists" do
    it "should create all the lists defined in the page_config" do
      context = setup_context :action=>:index do |config|
        config.resource {
          field(:name).show
          scope(:nested) do
            field(:age).show
          end
        }
        config.page(:index) {
          list
          list :nested, :scope=>:nested
        }
      end

      lists = context.lists
      expect(lists[0].formatters.size).to eq(1)
      expect(lists[0].formatters[0].field).to eq(:name)
      expect(lists[1].formatters.size).to eq(1)
      expect(lists[1].formatters[0].field).to eq(:age)
    end
  end

end
