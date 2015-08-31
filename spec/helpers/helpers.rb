require_relative 'errors'
require_relative 'expect'
require_relative 'trace'
require_relative 'utils'

require 'singleton'
require 'browsermob/proxy'

class SpecHelpers
  include Singleton
  attr_reader :browser, :protractor, :driver, :proxy

  def initialize
    browsermob_bin    = File.join(__dir__, 'browsermob-proxy-2.1.0-beta-2/bin/browsermob-proxy')
    browsermob_server = BrowserMob::Proxy::Server.new(browsermob_bin)

    browsermob_server.start
    @proxy = proxy = browsermob_server.create_proxy

    profile       = Selenium::WebDriver::Firefox::Profile.new
    profile.proxy = proxy.selenium_proxy


    # Chrome is required for the shadow dom test
    # Selenium::WebDriver::Chrome.driver_path = File.expand_path File.join(__dir__, '..', 'chromedriver')
    # @browser = Watir::Browser.new browser_name

    # Remote driver is useful for debugging
    begin
      @browser = Watir::Browser.new :remote, profile: profile, desired_capabilities: Selenium::WebDriver::Remote::Capabilities.send(browser_name)
    rescue # assume local browser if the remote doesn't connect
      # often the tests are running locally using a remote which fails on
      # travis since travis isn't setup for a remote browser.
      @browser = Watir::Browser.new browser_name, profile: profile
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

    # override stub methods
    AngularWebdriver.define_page_methods page_module:  ::Page,
                                         target_class: context,
                                         method:       :define_method,
                                         watir:        browser

    # set script timeout for protractor client side javascript
    # https://github.com/angular/protractor/issues/117
    _60_seconds                           = 60
    driver.manage.timeouts.script_timeout = _60_seconds
    # some browsers are slow to load.
    # https://github.com/angular/protractor/blob/6ebc4c3f8b557a56e53e0a1622d1b44b59f5bc04/spec/ciSmokeConf.js#L73
    #
    # Safari does not implement the page load timeout. Invoking it will cause
    # Unknown command: setTimeout
    driver.manage.timeouts.page_load      = _60_seconds unless driver.browser == :safari
    driver.manage.timeouts.implicit_wait  = 0

    # sometimes elements just don't exist even though the page has loaded
    # and wait for angular has succeeded. in these situations, use client wait.
    #
    # implicit wait shouldn't ever be used. client wait is a reliable replacement.
    driver.set_max_wait 10 # seconds
    driver.set_max_page_wait 30 # seconds

    # set window size
    driver.manage.window.resize_to 1024, 768
  end

  def driver_quit
    @proxy.close rescue nil
    @browser.quit rescue nil
  end
end
