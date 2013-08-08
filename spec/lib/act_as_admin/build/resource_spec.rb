require 'spec_helper'

describe ActAsAdmin::Build::Resource do
  it "should build controller path" do
    subject.path("users").to("orders").to("order_items")
    expect(subject.paths.first.parents.keys).to eq(["users", "orders", "order_items"])
  end
  
end