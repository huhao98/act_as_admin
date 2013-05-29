require 'spec_helper'

describe ActAsAdmin::Components::Nav do

  specify do
    nav_config = ActAsAdmin::Helpers::NavConfig.new.configure do |c|
      c.nav(:books)
      c.group(:users) do |g|
        g.nav(:orders)
        g.nav(:profiles)
      end
    end

    items = ActAsAdmin::Components::Nav.render(nav_config.nav_items) do |r|
      r.item do |key, cfg, opts|
        opts[:active] = true if key==:orders
        "#{key}"
      end

      r.group do |key, cfg, contents, active|
        "#{key}:#{active} - #{contents.join(",")}"
      end
    end

    expect(items.size).to eq(2)
    expect(items[0]).to eq("books")
    expect(items[1]).to eq("users:true - orders,profiles")
  end

end