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

# Define browser name at top level to selectively exclude browser specific
# tests within the spec files
def browser_name
  :firefox # must be a symbol
end

RSpec.configure do |config|
  config.before(:all) do
    # @browser = Watir::Browser.new browser_name

    # Chrome is required for the shadow dom test
    # Selenium::WebDriver::Chrome.driver_path = File.expand_path File.join(__dir__, '..', 'chromedriver')
    # @browser = Watir::Browser.new browser_name

    # Remote driver is useful for debugging
    begin
      @browser = Watir::Browser.new :remote, desired_capabilities: Selenium::WebDriver::Remote::Capabilities.send(browser_name)
    rescue # assume local browser if the remote doesn't connect
      # often the tests are running locally using a remote which fails on
      # travis since travis isn't setup for a remote browser.
      @browser = Watir::Browser.new browser_name
    end

    @driver = @browser.driver
    raise 'Driver is nil!' unless driver

    @driver.extend Selenium::WebDriver::DriverExtensions::HasTouchScreen
    @driver.extend Selenium::WebDriver::DriverExtensions::HasLocation

    # Must activate protractor before any driver commands
    @protractor = Protractor.new watir: @browser

    # Must call after Protractor.new and not before.
    AngularWebdriver.install_rspec_helpers

    # set script timeout for protractor client side javascript
    # https://github.com/angular/protractor/issues/117
    _60_seconds                           = 60
    driver.manage.timeouts.script_timeout = _60_seconds
    # some browsers are slow to load.
    #
    # will error with Unknown command: setTimeout on Safari 8
    #
    # https://github.com/angular/protractor/blob/6ebc4c3f8b557a56e53e0a1622d1b44b59f5bc04/spec/ciSmokeConf.js#L73

    driver.manage.timeouts.page_load      = _60_seconds

    driver.manage.timeouts.implicit_wait = 0

    # check protractor wait defaults
    expect(driver.max_wait_seconds).to eq(0)
    expect(driver.max_page_wait_seconds).to eq(30)

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
