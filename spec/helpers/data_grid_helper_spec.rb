require "spec_helper"

describe DataGridHelper do

  it "should render a list" do
    self.should_receive(:field_name).with(:name).and_return("Name")

    list = ActAsAdmin::Components.list :test do |resource_config, list_config|
      resource_config.field(:name).show
    end

    items = [
      {:name=>"A"}.to_ostruct,
      {:name=>"B"}.to_ostruct,
      {:name=>"C"}.to_ostruct
    ]

    html = list(list, items)
  end
end