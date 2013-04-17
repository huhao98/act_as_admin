$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "act_as_admin/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "act_as_admin"
  s.version     = ActAsAdmin::VERSION
  s.authors     = ["Brainet"]
  s.email       = ["huhao98@gmail.com"]
  s.homepage    = "http://brainet.github.com"
  s.summary     = "Summary of ActAsAdmin."
  s.description = "Description of ActAsAdmin."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 3.2.3"
  s.add_dependency 'twitter-bootstrap-rails', '= 2.2.0'
  s.add_dependency 'will_paginate-bootstrap', '= 0.2.2'
  s.add_dependency "mongoid", ">= 2.5.1"
  s.add_dependency 'bson_ext', "1.7.0"

  s.add_development_dependency 'quiet_assets'
  s.add_development_dependency 'rspec-rails', '~> 2.11.3'
  
end
