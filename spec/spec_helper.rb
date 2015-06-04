require 'rubygems'

# gems
require 'watir-webdriver'
require 'pry'
require 'webdriver_utils'

# stdlib
require 'json'
require 'ostruct'

# internal
require_relative '../lib/angular_webdriver'
require_relative 'helpers/helpers'

RSpec.configure do |config|
  config.before(:all) do
    @browser = Watir::Browser.new :firefox

    # Chrome is required for the shadow dom test
    # Selenium::WebDriver::Chrome.driver_path = File.expand_path File.join(__dir__, '..', 'chromedriver')
    # @browser = Watir::Browser.new :chrome

    # Remote driver is useful for debugging
    # @browser = Watir::Browser.new :remote, desired_capabilities: Selenium::WebDriver::Remote::Capabilities.firefox

    @driver  = @browser.driver
    raise 'Driver is nil!' unless driver

    @driver.extend Selenium::WebDriver::DriverExtensions::HasTouchScreen
    @driver.extend Selenium::WebDriver::DriverExtensions::HasLocation

    # Must activate protractor before any driver commands
    @protractor                           = Protractor.new driver: driver

    # set script timeout for protractor client side javascript
    # https://github.com/angular/protractor/issues/117
    _60_seconds                           = 60
    driver.manage.timeouts.script_timeout = _60_seconds
    # some browsers are slow to load.
    # https://github.com/angular/protractor/blob/6ebc4c3f8b557a56e53e0a1622d1b44b59f5bc04/spec/ciSmokeConf.js#L73
    driver.manage.timeouts.page_load      = _60_seconds
    raise 'incorrect driver wait seconds default' unless driver.max_wait_seconds == 0

    # sometimes elements just don't exist even though the page has loaded
    # and wait for angular has succeeded. in these situations, use client wait.
    #
    # implicit wait shouldn't ever be used. client wait is a reliable replacement.
    driver.set_max_wait max_wait_seconds_default # seconds
  end

  config.after(:all) do
    driver.quit rescue nil
  end
end
