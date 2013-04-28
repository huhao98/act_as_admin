module ActAsAdmin
  class Engine < ::Rails::Engine
    config.nav = ActAsAdmin::Helpers::NavConfig.new
  end
end
