require "spec_helper"

describe ListHelper do

  it "should render a list" do
    self.stub!(:field_name).and_return("Name")

    list = ActAsAdmin::Components.list :test do |resource_config, list_config|
      resource_config.field(:name).show
    end

    items = [
      {:name=>"A"}.to_ostruct,
      {:name=>"B"}.to_ostruct,
      {:name=>"C"}.to_ostruct
    ]

    html = data_grid(list, items)
  end
end