Dir[File.join(File.dirname(__FILE__),"locales/*.yml")].each do |yml|
  I18n.load_path << yml
end

module ActAsAdmin
  autoload :Controller, 'act_as_admin/controller'
  autoload :Config, 'act_as_admin/config'
  autoload :Components, 'act_as_admin/components/list'
  module Helpers
    autoload :PathHelper, 'act_as_admin/helpers/path_helper'
    autoload :QueryParams, 'act_as_admin/helpers/query_params'
    autoload :NavConfig, 'act_as_admin/helpers/nav_config'
  end
  module Controller
    autoload :MongoQueryExecutor, 'act_as_admin/controller/mongo_query_executor'
    autoload :MongoQueryResult, 'act_as_admin/controller/mongo_query_result'
  end
  module Components
    autoload :Form, 'act_as_admin/components/form'
    autoload :List, 'act_as_admin/components/list'
    autoload :Formatter, 'act_as_admin/components/formatter'
  end
end

require "act_as_admin/engine"