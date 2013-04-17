module ActAsAdmin
  autoload :NavConfig, 'act_as_admin/nav_config'
  autoload :Controller, 'act_as_admin/controller'
  autoload :ViewResolver, 'act_as_admin/view_resolver'
  autoload :Config, 'act_as_admin/config'
  module Helpers
    autoload :PathHelper, 'act_as_admin/helpers/path_helper'
    autoload :NavHelper, 'act_as_admin/helpers/nav_helper'
  end
end

require "act_as_admin/engine"