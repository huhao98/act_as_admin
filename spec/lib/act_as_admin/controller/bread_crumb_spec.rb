require 'spec_helper'

describe ActAsAdmin::Controller::BreadCrumb do
  setup_context

  let(:controller) do
    controller = mock("Controller")
    controller.extend(::ActAsAdmin::Controller::BreadCrumb)
    controller.extend(::ActAsAdmin::Helpers::PathHelper)
    controller.instance_variable_set("@context", context)
    controller
  end

  describe 'breadcrumbs' do
    before(:each){controller.instance_variable_set("@resource", dummy)}

    it "should add breadcrumb with link resolved by link proc" do
      context.stub(
        :page=>mock("Page", :breadcrumbs=>{
          "Dummies"=>{:link=> ->{resources_path}}
        })
      )

      controller.should_receive(:dummies_path).with(no_args).and_return("/dummies")
      controller.should_receive(:add_breadcrumb).with("Dummies", "/dummies")
      controller.breadcrumbs
    end

    it "should add breadcrumb with name and link resolved by proc" do
      context.stub(
        :page=>mock("Page", :breadcrumbs=>{
          :resource => {:link => ->{["A dummy", resource_path(@resource)]}}
        })
      )

      controller.should_receive(:dummy_path).with(dummy).and_return("/dummy/dummy_id")
      controller.should_receive(:add_breadcrumb).with("A dummy", "/dummy/dummy_id")
      controller.breadcrumbs
    end

    it "should not add breadcrumb given the link proc returns nil" do
      context.stub(
        :page=>mock("Page", :breadcrumbs=>{:resources => {:link=> ->{nil}}})
      )

      controller.should_not_receive(:add_breadcrumb)
      controller.breadcrumbs
    end

    it "should add breadcrumb without link when no link proc is given" do
      context.stub(
        :page=>mock("Page", :breadcrumbs=>{"Edit" => {}})
      )

      controller.should_receive(:add_breadcrumb).with("Edit")
      controller.breadcrumbs
    end

    it "should add breadcrums for parents given parents presented" do
      context.stub(
        :parents=>{parent=>{:title_field=>:title, :resource_name=>:parent}},
        :page=>mock("Page", :breadcrumbs=>{"Dummy"=>{:link=>->{resources_path}}})
      )

      controller.should_receive(:parents_path).with(no_args).and_return("/parents")
      controller.should_receive(:parent_path).with(parent).and_return("/parents/parent_id")
      controller.should_receive(:parent_dummies_path).with(parent).and_return("/parents/parent_id/dummies")

      controller.should_receive(:add_breadcrumb).with("Parent", "/parents").ordered
      controller.should_receive(:add_breadcrumb).with("A Parent", "/parents/parent_id").ordered
      controller.should_receive(:add_breadcrumb).with("Dummy", "/parents/parent_id/dummies").ordered

      controller.breadcrumbs
    end

  end

end
