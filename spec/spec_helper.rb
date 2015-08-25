require 'rubygems'

# gems
require 'simplecov'
require 'coveralls'

# Exclude spec directory from coverage reports.
SimpleCov.start do
  add_filter '/spec'
end

require 'page_object'
require 'watir-webdriver'
require 'pry'
require 'webdriver_utils'

# stdlib
require 'json'
require 'ostruct'

# internal
require_relative '../lib/angular_webdriver'
require_relative 'helpers/helpers'

Pry.pager = nil if defined?(Pry) # disable pry paging

AngularWebdriver.require_all_pages

# Define browser name at top level to selectively exclude browser specific
# tests within the spec files
def browser_name
  :firefox # must be a symbol
end

spec_helpers = SpecHelpers.instance

RSpec.configure do |config|
  config.include ExpectHelpers

  user = ENV['USER']

  def exclude_pattern regex_string
    /^#{Regexp.escape regex_string}/
  end

  osx_rvm_gems                        = exclude_pattern "/Users/#{user}/.rvm/gems/"
  linux_rvm_gems                      = exclude_pattern "/home/#{user}/.rvm/gems/"
  config.backtrace_exclusion_patterns = [osx_rvm_gems, linux_rvm_gems]

  config.before(:all) do # describes
    # sometimes elements just don't exist even though the page has loaded
    # and wait for angular has succeeded. in these situations, use client wait.
    #
    # implicit wait shouldn't ever be used. client wait is a reliable replacement.
    driver.set_max_wait max_wait_seconds_default # seconds
    driver.set_max_page_wait max_page_wait_seconds_default
  end

  config.before(:each) do # its
    # verify the waits are set to the expected value (10, 30)
    expect(driver.max_wait_seconds).to eq(max_wait_seconds_default)
    expect(driver.max_page_wait_seconds).to eq(max_page_wait_seconds_default)
  end
end

at_exit { spec_helpers.driver_quit rescue nil }
