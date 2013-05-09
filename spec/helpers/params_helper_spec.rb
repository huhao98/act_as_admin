require 'spec_helper'

describe ParamsHelper do
  before :each do
    params[:controller] = "calls"
  end

  it "should set filter field value" do
    params[:f] = {:age=>5}
    expect(filter(:age, 10).query_params[:f]).to eq(:age=>10)
  end

  it "should remove filter field value" do
    params[:f] = {:age=>10, :name=>"test"}
    expect(filter(:age).query_params[:f]).to eq(:name=>"test")
  end

end
