# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../rcov.rb",  __FILE__)
require File.expand_path("../dummyapp/config/environment.rb",  __FILE__)
require 'mongoid'
require "action_controller/railtie"
require 'act_as_admin'
require 'act_as_admin/config'
require 'rspec'
require 'rspec/rails'


Dir["spec/support/**/*.rb"].each {|f| require File.expand_path(f)}
RSpec.configure do |config|
  config.order = "random"
  config.include DummyModels
end