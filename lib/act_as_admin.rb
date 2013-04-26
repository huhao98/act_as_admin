Dir[File.join(File.dirname(__FILE__),"locales/*.yml")].each do |yml|
  I18n.load_path << yml
end

module ActAsAdmin
  autoload :Controller, 'act_as_admin/controller'
  autoload :Config, 'act_as_admin/config'
  module Helpers
    autoload :PathHelper, 'act_as_admin/helpers/path_helper'
    autoload :NavConfig, 'act_as_admin/helpers/nav_config'
  end
  module Controller
    autoload :MongoQuery, 'act_as_admin/controller/mongo_query'
  end
end

require "act_as_admin/engine"