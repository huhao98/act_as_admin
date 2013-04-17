require 'spec_helper'

describe ActAsAdmin::NavConfig do
  let(:config){ActAsAdmin::NavConfig.new}

  it "should add nav items in order" do
    config.nav_item("Nav1", :url=>"/")
    config.nav_model("Model")
    config.nav_models("Group", ["GroupModel1", "GroupModel2"])

    expect(config.nav_items.size).to eq(3)
    expect(config.nav_items[0]).to eq(:title=>"Nav1", :url=>"/")
    expect(config.nav_items[1]).to eq(:model=>"Model")
    expect(config.nav_items[2]).to eq(:title=>"Group", :models=>["GroupModel1", "GroupModel2"])
  end

  it "nav_item take optional block as :url option" do
    config.nav_item("Nav1"){}

    expect(config.nav_items[0][:title]).to eq("Nav1")
    expect(config.nav_items[0][:url]).to be_a(Proc)
  end

end