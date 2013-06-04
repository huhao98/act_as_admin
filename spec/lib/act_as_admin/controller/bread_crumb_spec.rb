require 'spec_helper'

describe ActAsAdmin::Controller::BreadCrumb do
  
  
  def setup_controller params
    config = ActAsAdmin::Config.new(:model=>::Dummy, :resource_name=>"dummy")
    config.resource{path(:dummies, :title=>:name)}

    yield(config) if block_given?
    context = ActAsAdmin::Controller::Context.new(config, params.with_indifferent_access)

    controller = mock("Controller")
    controller.extend(::ActAsAdmin::Controller::BreadCrumb)
    controller.extend(::ActAsAdmin::Helpers::PathHelper)
    controller.instance_variable_set("@context", context)
    return controller
  end

  describe 'breadcrumbs' do
    it "should add default breadcrumbs for resources" do
      controller = setup_controller(:action=>"index")

      controller.should_receive(:dummies_path).with(no_args).and_return("/dummies")
      controller.should_receive(:add_breadcrumb).with("Dummy", "/dummies").ordered

      controller.breadcrumbs      
    end

    it "should add default breadcrumbs for resource" do
      controller = setup_controller(:action=>"show", :id=>"dummy_id")

      controller.should_receive(:dummies_path).with(no_args).and_return("/dummies")
      controller.should_receive(:dummy_path).with(dummy).and_return("/dummies/dummy_id")
      controller.should_receive(:add_breadcrumb).with("Dummy", "/dummies").ordered
      controller.should_receive(:add_breadcrumb).with("A Dummy", "/dummies/dummy_id").ordered
      
      controller.breadcrumbs
    end

    it "should add page level breadcrumbs for resources" do
      controller = setup_controller(:action=>"new") do |config|
        config.page(:new) do
          breadcrumb{add_breadcrumb "New Dummy", new_resource_path}
        end
      end

      controller.should_receive(:dummies_path).with(no_args).and_return("/dummies")
      controller.should_receive(:new_dummy_path).with(no_args).and_return("/dummies/new")
      controller.should_receive(:add_breadcrumb).with("Dummy", "/dummies").ordered
      controller.should_receive(:add_breadcrumb).with("New Dummy", "/dummies/new").ordered

      controller.breadcrumbs
    end

    it "should add page level breadcrumbs for resource" do
      controller = setup_controller(:action=>"edit", :id=>"dummy_id") do |config|
        config.page(:edit) do
          breadcrumb{add_breadcrumb "Edit A Dummy", edit_resource_path(@resource)}
        end
      end

      controller.instance_variable_set("@resource", dummy)
      controller.should_receive(:dummies_path).with(no_args).and_return("/dummies")
      controller.should_receive(:dummy_path).with(dummy).and_return("/dummies/dummy_id")
      controller.should_receive(:edit_dummy_path).with(dummy).and_return("/dummies/dummy_id/edit")
      controller.should_receive(:add_breadcrumb).with("Dummy", "/dummies").ordered
      controller.should_receive(:add_breadcrumb).with("A Dummy", "/dummies/dummy_id").ordered
      controller.should_receive(:add_breadcrumb).with("Edit A Dummy", "/dummies/dummy_id/edit").ordered
      
      controller.breadcrumbs
    end

    it "should add resources breadcrums with parents" do
      parent.stub(:name=>"A Parent")
      controller = setup_controller(:action=>"index", :parent_id=>"parent_id") do |config|
        config.resource_config.path(:parents, :title=>:name).to(:dummies)
      end

      controller.should_receive(:parents_path).with(no_args).and_return("/parents")
      controller.should_receive(:parent_path).with(parent).and_return("/parents/parent_id")
      controller.should_receive(:parent_dummies_path).with(parent).and_return("/parents/parent_id/dummies")

      controller.should_receive(:add_breadcrumb).with("Parent", "/parents").ordered
      controller.should_receive(:add_breadcrumb).with("A Parent", "/parents/parent_id").ordered
      controller.should_receive(:add_breadcrumb).with("Dummy", "/parents/parent_id/dummies").ordered

      controller.breadcrumbs
    end

    it "should add resource breadcrums with parents" do
      parent.stub(:name=>"A Parent")
      dummy.stub(:title=>"A Dummy")

      controller = setup_controller(:action=>"index", :parent_id=>"parent_id", :id=>"dummy_id") do |config|
        config.resource_config.path(:parents, :title=>:name).to(:dummies, :title=>:title)
      end

      controller.should_receive(:parents_path).with(no_args).and_return("/parents")
      controller.should_receive(:parent_path).with(parent).and_return("/parents/parent_id")
      controller.should_receive(:parent_dummies_path).with(parent).and_return("/parents/parent_id/dummies")
      controller.should_receive(:parent_dummy_path).with(parent, dummy).and_return("/parents/parent_id/dummies/dummy_id")

      controller.should_receive(:add_breadcrumb).with("Parent", "/parents").ordered
      controller.should_receive(:add_breadcrumb).with("A Parent", "/parents/parent_id").ordered
      controller.should_receive(:add_breadcrumb).with("Dummy", "/parents/parent_id/dummies").ordered
      controller.should_receive(:add_breadcrumb).with("A Dummy", "/parents/parent_id/dummies/dummy_id").ordered

      controller.breadcrumbs
    end

  end

end
