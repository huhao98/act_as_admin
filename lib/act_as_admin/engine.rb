module ActAsAdmin
  class Engine < ::Rails::Engine
    config.nav = ActAsAdmin::NavConfig.new
  end
end
