require 'spec_helper'

describe ActAsAdmin::Helpers::NavConfig do
  let(:config){ActAsAdmin::Helpers::NavConfig.new}

  it "should add nav items in order" do
    config.nav("Nav1", :url=>"/")
    config.nav(:user)
    config.nav(:fruits, :resources=>[:apple, :orange])

    expect(config.nav_items.size).to eq(3)
    expect(config.nav_items).to eq({
      "Nav1" => {:url=>"/"},
      :user => {},
      :fruits => {:resources=>[:apple, :orange]}
    })
  end

  it "nav_item take optional block as :url option" do
    config.nav("Nav1"){}

    nav1 = config.nav_items["Nav1"]
    expect(nav1).not_to be_nil
    expect(nav1[:url]).to be_a(Proc)
  end

end