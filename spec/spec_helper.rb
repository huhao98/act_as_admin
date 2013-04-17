# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

if( ENV['RCOV'] == 'on' )
  require 'simplecov'
  require 'simplecov-rcov'
  class SimpleCov::Formatter::MergedFormatter
    def format(result)
      SimpleCov::Formatter::HTMLFormatter.new.format(result)
      SimpleCov::Formatter::RcovFormatter.new.format(result)
    end
  end
  SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter
  SimpleCov.start 'test_frameworks'
end


require File.expand_path("../dummyapp/config/environment.rb",  __FILE__)

require 'mongoid'
require "action_controller/railtie"
require 'act_as_admin'
require 'rspec'
require 'rspec/rails'

RSpec.configure do |config|
  config.order = "random"
end
