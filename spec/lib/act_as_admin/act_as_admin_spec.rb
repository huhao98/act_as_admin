require "spec_helper"

describe ActAsAdmin::Controller do

  before :each do
    class DummyModel
      extend ActiveModel::Naming
    end

    class ParentModel < DummyModel;end

    class DummyController
      def self.append_view_path resolver
      end

      def self.before_filter name, opts={}
      end
      include ActAsAdmin::Controller
    end
  end

  after :each do
    Object.send(:remove_const, :DummyController)
    Object.send(:remove_const, :DummyModel)
    Object.send(:remove_const, :ParentModel)
  end

  describe "register" do
    it "should append view path" do
      DummyController.should_receive(:append_view_path).with(an_instance_of(ActAsAdmin::ViewResolver))

      DummyController.register_model DummyModel
    end

    describe "filters" do     
      it "should define resource filters" do
        DummyController.should_receive(:before_filter).with(:initialize_data).ordered
        DummyController.should_receive(:before_filter).with(:find_parents).ordered
        DummyController.should_receive(:before_filter).with(:new_resource, :only=>[:new, :create]).ordered
        DummyController.should_receive(:before_filter).with(:find_resource, :only=>[:show, :destroy, :edit, :update]).ordered
        DummyController.should_receive(:before_filter).with(:find_resources).ordered
        DummyController.should_receive(:before_filter).with(:breadcrumbs).ordered

        

        DummyController.register_model DummyModel do
          parent ParentModel, :on=>:dummies
        end

        controller = DummyController.new

        controller.should respond_to(:initialize_data)
        controller.should respond_to(:find_parents)
        controller.should respond_to(:new_resource)
        controller.should respond_to(:find_resource)
        controller.should respond_to(:find_resources)
        controller.should respond_to(:breadcrumbs)
      end
    end

    describe "default configuration" do
      before :each do
        DummyController.register_model DummyModel
      end

      it "should create default query for index page" do
        query = DummyController.admin_config.queries[:index]
        query.should_not be_nil
        query.per_page.should == 10
        query.path_proc.should be_a(Proc)
        query.as.should be_nil
        query.on.should be_nil
      end

      it "should create default form for new and edit action" do
        form = DummyController.admin_config.default_form
        form.should_not be_nil
        form.should == DummyController.admin_config.forms[:new]
        form.should == DummyController.admin_config.forms[:edit]

        form.actions[:edit][:action_url].should be_a(Proc)
        form.actions[:edit][:method].should eq(:put)

        form.actions[:new][:action_url].should be_a(Proc)
        form.actions[:new][:method].should eq(:post)
      end

      it "should create index page" do
        index_page = DummyController.admin_config.pages[:index]

        expect(index_page).not_to be_nil
        expect(index_page.actions.size).to eq(1)
        expect(index_page.actions[:new]).not_to be_nil
        expect(index_page.data_actions.size).to eq(2)
        expect(index_page.data_actions[:edit]).not_to be_nil
        expect(index_page.data_actions[:delete]).not_to be_nil
        expect(index_page.breadcrumbs.size).to eq(1)
      end

      it "should create show page" do
        show_page = DummyController.admin_config.pages[:show]
        expect(show_page).not_to be_nil
        expect(show_page.actions.size).to eq(2)
        expect(show_page.actions[:edit]).not_to be_nil
        expect(show_page.actions[:delete]).not_to be_nil
        expect(show_page.breadcrumbs.size).to eq(2)
      end

      it "should create new page" do
        new_page = DummyController.admin_config.pages[:new]
        new_form = DummyController.admin_config.forms[:new]

        expect(new_page.actions.size).to eq(1)
        expect(new_page.actions[:cancel]).not_to be_nil
        expect(new_page.breadcrumbs.size).to eq(2)

        expect(new_form.actions[:new]).not_to be_nil
        expect(new_form.actions[:new][:method]).to eq(:post)
      end

      it "should create edit page" do
        edit_page = DummyController.admin_config.pages[:edit]
        edit_form = DummyController.admin_config.forms[:edit]

        expect(edit_page.actions.size).to eq(1)
        expect(edit_page.actions[:cancel]).not_to be_nil
        expect(edit_page.breadcrumbs.size).to eq(3)
        expect(edit_form.actions[:edit]).not_to be_nil
        expect(edit_form.actions[:edit][:method]).to eq(:put)
      end
    end

  end
end
