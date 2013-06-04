require "spec_helper"

describe ActAsAdmin::Controller do

  before :each do
    class DummyController
      def self.append_view_path resolver;end
      def self.before_filter name, opts={};end
      include ActAsAdmin::Controller
    end
  end

  after :each do
    Object.send(:remove_const, :DummyController)
  end

  describe "register" do
    it "should append view paths" do
      DummyController.should_receive(:append_view_path).twice
      DummyController.register_model Dummy
    end

    describe "filters" do
      it "should define resource filters" do
        DummyController.should_receive(:before_filter).with(:init_context).ordered
        DummyController.should_receive(:before_filter).with(:new_resource, :only=>[:new, :create]).ordered
        DummyController.should_receive(:before_filter).with(:find_resource, :only=>[:show, :destroy, :edit, :update]).ordered
        DummyController.should_receive(:before_filter).with(:find_resources).ordered
        DummyController.should_receive(:before_filter).with(:breadcrumbs).ordered

        DummyController.register_model Dummy
        controller = DummyController.new

        controller.should respond_to(:init_context)
        controller.should respond_to(:new_resource)
        controller.should respond_to(:find_resource)
        controller.should respond_to(:find_resources)
        controller.should respond_to(:breadcrumbs)
      end
    end

    describe "default configuration" do
      before :each do
        DummyController.register_model Dummy
      end

     specify "index page" do
        index_page = DummyController.admin_config.pages[:index]

        expect(index_page).not_to be_nil
        expect(index_page.actions.size).to eq(1)
        expect(index_page.actions[:new]).not_to be_nil
        expect(index_page.headers[:major]).not_to be_nil
      end

      specify "index page has default query config" do
        query_config = DummyController.admin_config.pages[:index].queries[:default]

        query_config.should_not be_nil
        query_config.per_page.should == 10
        query_config.path_proc.should be_a(Proc)
        query_config.as.should be_nil
      end

      specify "index page has default list config" do
        list_config = DummyController.admin_config.pages[:index].lists[:default]

        expect(list_config.actions[:edit]).not_to be_nil
        expect(list_config.actions[:delete]).not_to be_nil
        expect(list_config.actions[:delete][:method]).to eq("delete")
      end

      specify "show page" do
        show_page = DummyController.admin_config.pages[:show]
        expect(show_page).not_to be_nil
        expect(show_page.actions[:edit]).not_to be_nil
        expect(show_page.actions[:delete]).not_to be_nil
        expect(show_page.actions[:delete][:method]).to eq("delete")
      end

      specify "show page default list" do
        list_config = DummyController.admin_config.pages[:show].lists[:default]

        expect(list_config).not_to be_nil
        expect(list_config.actions).to be_empty
      end

      specify "new page" do
        page = DummyController.admin_config.pages[:new]
        expect(page.breadcrumbs.size).to eq(1)
      end

      specify "new page has default form" do
        form_config = DummyController.admin_config.pages[:new].forms[:default]
        expect(form_config.as).to eq("dummy")
        expect(form_config.submit_label).to eq(:create)
        expect(form_config.cancel_label).to eq(:cancel)
        expect(form_config.method).to eq(:post)
      end
      specify "edit page" do
        page = DummyController.admin_config.pages[:edit]
        expect(page.breadcrumbs.size).to eq(1)
      end

      specify "edit page has default form" do
        form_config = DummyController.admin_config.pages[:edit].forms[:default]
        expect(form_config.as).to eq("dummy")
        expect(form_config.submit_label).to eq(:update)
        expect(form_config.cancel_label).to eq(:cancel)
        expect(form_config.method).to eq(:put)
      end
    end


  end
end
