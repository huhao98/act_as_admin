require "admin/engine"

module Admin
  autoload :ActAsAdmin, 'admin/act_as_admin'
  autoload :ViewResolver, 'admin/view_resolver'
  module Helpers
    autoload :PathHelper, 'admin/helpers/path_helper'
    autoload :NavHelper, 'admin/helpers/nav_helper'
  end
end