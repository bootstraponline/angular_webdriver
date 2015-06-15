require_relative 'errors'
require_relative 'expect'
require_relative 'trace'
require_relative 'utils'

require 'singleton'

class SpecHelpers
  include Singleton

  attr_reader :browser, :protractor, :driver

  def initialize
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

    # Promote SpecHelpers onto RSpec as well.
    context         = ::RSpec::Core::ExampleGroup
    helper_instance = self
    self.class.instance_methods(false).each do |method_symbol|
      context.send(:define_method, method_symbol) do |*args, &block|
        args.length == 0 ? helper_instance.send(method_symbol, &block) :
          helper_instance.send(method_symbol, *args, &block)
      end
    end

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
  end

  def driver_quit
    @browser.quit rescue nil
  end
end
