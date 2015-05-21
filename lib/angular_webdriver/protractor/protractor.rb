require 'rubygems'
require 'selenium-webdriver'
require 'selenium/webdriver/common/error'

require_relative 'webdriver_patch'
require_relative 'client_side_scripts'

class Protractor
  # code/comments from protractor/lib/protractor.js
  attr_accessor :root_element, :ignore_sync

  attr_reader :client_side_scripts, :driver, :reset_url, :base_url

  # The css selector for an element on which to find Angular. This is usually
  # 'body' but if your ng-app is on a subsection of the page it may be
  # a subelement.
  #
  # @return [String]
  def self.root_element
    @@root_element
  end

  # The css selector for an element on which to find Angular. This is usually
  # 'body' but if your ng-app is on a subsection of the page it may be
  # a subelement.
  #
  # @return [String]
  def root_element
    @@root_element
  end

  #  @see webdriver.WebDriver.get
  #
  #  Navigate to the given destination. Assumes that the page being loaded uses Angular.
  #  If you need to access a page which does not have Angular on load, set
  #  ignore_sync to true before invoking get
  #
  #  @example
  #  browser.get('https://angularjs.org/');
  #  expect(browser.getCurrentUrl()).toBe('https://angularjs.org/');
  #
  # @param destination [String] The destination URL to load, can be relative if base_url is set
  # @param opt_timeout [Integer] Number of seconds to wait for Angular to start. Default 30.
  def get destination, opt_timeout
    timeout = opt_timeout ? opt_timeout : 30

    destination = base_url.start_with?('file://') ?
      base_url + destination : URI.join(base_url, destination)

    msg = lambda { |str| 'Protractor.get(' + destination + ') - ' + str }

    return driver.get(destination) if ignore_sync

    driver.get(reset_url)
    executeScript_(
      'window.location.replace("' + destination + '");',
      msg.call('reset url'))

    wait(timeout) do
      url = executeScript_('return window.location.href;', msg('get url'))
      raise 'still on reset url' unless url != reset_url
    end

    # now that the url has changed, make sure Angular has loaded
    # note that the mock module logic is omitted.
    waitForAngular
  end

  #  @see webdriver.WebDriver.refresh
  #
  #  Makes a full reload of the current page and loads mock modules before
  #  Angular. Assumes that the page being loaded uses Angular.
  #  If you need to access a page which does not have Angular on load, use
  #  the wrapped webdriver directly.
  #
  #  @param opt_timeout [Integer] Number of seconds to wait for Angular to start.
  def refresh opt_timeout
    timeout = opt_timeout || 10

    return driver.navigate.refresh if ignore_sync

    executeScript_('return window.location.href;',
                   'Protractor.refresh() - getUrl')

    get(href, timeout)
  end

  #  Browse to another page using in-page navigation.
  #
  #  @example
  #  browser.get('http://angular.github.io/protractor/#/tutorial');
  #  browser.setLocation('api');
  #  expect(browser.getCurrentUrl())
  #      .toBe('http://angular.github.io/protractor/#/api');
  #
  #  @param url [String] In page URL using the same syntax as $location.url()
  #
  def setLocation url
    waitForAngular

    begin
      executeScript_(client_side_scripts.set_location,
                     'Protractor.setLocation()', [root_element, url])
    rescue Exception => e
      raise e.class, "Error while navigating to '#{url}' : #{e}"
    end
  end

  #  Returns the current absolute url from AngularJS.
  #
  #  @example
  #  browser.get('http://angular.github.io/protractor/#/api');
  #  expect(browser.getLocationAbsUrl())
  #      .toBe('http://angular.github.io/protractor/#/api');
  #
  def getLocationAbsUrl
    waitForAngular
    executeScript_(client_side_scripts.get_location_abs_url,
                   'Protractor.getLocationAbsUrl()', root_element)
  end

  # Creates a new protractor instance and dynamically patches the provided
  # driver.
  #
  # @param [Hash] opts the options to initialize with
  # @option opts [String]  :root_element the root element on which to find Angular
  # @option opts [Boolean] :ignore_sync if true, Protractor won't auto sync the page
  def initialize opts={}
    @driver = opts[:driver]
    raise 'Must supply Selenium::WebDriver' unless @driver

    watir   = defined?(Watir::Browser) && @driver.is_a?(Watir::Browser)
    @driver = watir ? @driver.driver : @driver

    @driver.protractor = self

    # The css selector for an element on which to find Angular. This is usually
    # 'body' but if your ng-app is on a subsection of the page it may be
    # a subelement.
    #
    # @return [String]
    @@root_element     = opts.fetch :root_element, 'body'

    # If true, Protractor will not attempt to synchronize with the page before
    # performing actions. This can be harmful because Protractor will not wait
    # until $timeouts and $http calls have been processed, which can cause
    # tests to become flaky. This should be used only when necessary, such as
    # when a page continuously polls an API using $timeout.
    #
    # @return [Boolean]
    @ignore_sync       = !!opts.fetch(:ignore_sync, false)

    @client_side_scripts = ClientSideScripts

    browser_name = driver.capabilities[:browser_name].strip
    if ['internet explorer', 'safari'].include?(browser_name)
      @reset_url = 'about:blank'.freeze
    else
      @reset_url = 'data:text/html,<html></html>'.freeze
    end

    @base_url = URI.parse opts.fetch(:base_url, '')
  end

  # Syncs the webdriver command if it's whitelisted
  #
  # @param webdriver_command [Symbol] the webdriver command to check for syncing
  def sync webdriver_command
    return unless webdriver_command
    webdriver_command = webdriver_command.intern
    sync_whitelist    = [
      :getCurrentUrl, :get, :refresh, :getPageSource,
      :getTitle, :findElement, :findElements,
      :findChildElement, :findChildElements,
      :setLocation
    ]
    must_sync         = sync_whitelist.include? webdriver_command

    self.waitForAngular if must_sync
  end

  # Instruct webdriver to wait until Angular has finished rendering and has
  # no outstanding $http or $timeout calls before continuing.
  # Note that Protractor automatically applies this command before every
  # WebDriver action.
  #
  # @param [String] opt_description An optional description to be added
  #     to webdriver logs.
  # @return [WebDriver::Element, Integer, Float, Boolean, NilClass, String, Array]
  def waitForAngular opt_description='' # Protractor.prototype.waitForAngular
    return if ignore_sync

    begin
      # the client side script will return a string on error
      # the string won't be raised as an error unless we explicitly do so here
      error = executeAsyncScript_(client_side_scripts.wait_for_angular,
                                  "Protractor.waitForAngular() #{opt_description}",
                                  root_element)
      raise Selenium::WebDriver::Error::JavascriptError, error if error
    rescue Exception => e
      # https://github.com/angular/protractor/blob/master/docs/faq.md
      raise e.class, "Error while waiting for Protractor to sync with the page: #{e}"
    end
  end

  # Ensure description is exactly one line that ends in a newline
  # must use /* */ not // due to some browsers having problems
  # with // comments when used with execute script
  def _js_comment description
    description = description ? '/* ' + description.gsub(/\W+/, ' ') + ' */' : ''
    description.strip + "\n"
  end

  # The same as {@code webdriver.WebDriver.prototype.executeAsyncScript},
  # but with a customized description for debugging.
  #
  #  @private
  #  @param script [String] The javascript to execute.
  #  @param description [String]  A description of the command for debugging.
  #  @param args [var_args] The arguments to pass to the script.
  #  @return The scripts return value.
  def executeAsyncScript_ script, description, *args
    # add description as comment to script so it shows up in server logs
    script = _js_comment(description) + script

    driver.execute_async_script script, args
  end

  #  The same as {@code webdriver.WebDriver.prototype.executeScript},
  #  but with a customized description for debugging.
  #
  #  @private
  #  @param script [String] The javascript to execute.
  #  @param description [String]  A description of the command for debugging.
  #  @param args [var_args] The arguments to pass to the script.
  #  @return The scripts return value.
  def executeScript_ script, description, *args
    # add description as comment to script so it shows up in server logs
    script = _js_comment(description) + script

    driver.execute_script script, args
  end

  #  Adds a task to the control flow to pause the test and inject helper functions
  #  into the browser, so that debugging may be done in the browser console.
  #
  #  This should be used under Pry
  def debugger
    executeScript_ client_side_scripts.install_in_browser, 'Protractor.debugger()'
  end
end
