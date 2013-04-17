# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require 'mongoid'
require "action_controller/railtie"
require 'act_as_admin'
require 'rspec'

Dir["spec/support/**/*.rb"].each {|f| require File.expand_path(f)}
RSpec.configure do |config|
  config.order = "random"
end
