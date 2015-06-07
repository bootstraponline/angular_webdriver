require 'selenium/webdriver/common/error'

class Protractor

  NEW_FINDERS_KEYS = %i(
    binding
    exactBinding
    partialButtonText
    buttonText
    model
    options
    cssContainingText
    repeater
  ).freeze # [:binding]
  NEW_FINDERS_HASH = NEW_FINDERS_KEYS.map { |e| [e, e.to_s] }.to_h.freeze # {binding: 'binding'}

  # Return true if given finder is a protractor finder.
  #
  # @param finder_name [Symbol|String] the name of the finder
  #
  # @return [boolean]
  def finder? finder_name
    NEW_FINDERS_KEYS.include? finder_name.intern
  end

  # code/comments from protractor/lib/protractor.js

  # The css selector for an element on which to find Angular. This is usually
  # 'body' but if your ng-app is on a subsection of the page it may be
  # a subelement.
  #
  # @return [String]
  #
  attr_accessor :root_element

  # If true, Protractor will not attempt to synchronize with the page before
  # performing actions. This can be harmful because Protractor will not wait
  # until $timeouts and $http calls have been processed, which can cause
  # tests to become flaky. This should be used only when necessary, such as
  # when a page continuously polls an API using $timeout.
  #
  # @return [Boolean]
  #
  attr_accessor :ignore_sync

  # File.join(base_url, destination) when using driver.get and
  # protractor.get (if sync is on, base_url is set, and destination
  # is not absolute).
  #
  # @return [String] Default nil.
  #
  attr_reader :base_url

  # Sets the base url.
  #
  # Expected format:
  # scheme://host
  #
  # Example:
  # http://localhost
  #
  # @param url [String] the url to use as a base
  #
  # @return [String] url
  def base_url= url
    # Allow resetting base_url with falsey value
    return @base_url = nil unless url

    uri = URI.parse(url) rescue false
    raise "Invalid URL #{url.inspect}. Must contain scheme and host." unless uri && uri.scheme && uri.host
    @base_url = url
  end

  #  All scripts to be run on the client via executeAsyncScript or
  #  executeScript should be put here.
  #
  #  NOTE: These scripts are transmitted over the wire as JavaScript text
  #  constructed using their toString representation, and# cannot*
  #  reference external variables.
  #
  #  Some implementations seem to have issues with // comments, so use star-style
  #  inside scripts. that caused the switch to avoid the // comments.)
  #
  attr_reader :client_side_scripts

  # The Selenium::WebDriver driver object
  attr_reader :driver

  # URL to a blank page. Differs depending on the browser.
  # @see reset_url_for_browser
  #
  attr_reader :reset_url

  #  @see webdriver.WebDriver.get
  #
  #  Navigate to the given destination. Assumes that the page being loaded uses Angular.
  #  If you need to access a page which does not have Angular on load,
  #  use driver_get.
  #
  #  @example
  #  browser.get('https://angularjs.org/');
  #  expect(browser.getCurrentUrl()).toBe('https://angularjs.org/');
  #
  # @param destination [String] The destination URL to load, can be relative if base_url is set
  # @param opt_timeout [Integer] Number of seconds to wait for Angular to start.
  #                              Default 30
  #
  def get destination, opt_timeout=driver.max_page_wait_seconds
    # do not use driver.get because that redirects to this method
    # instead driver_get is provided.

    timeout = opt_timeout

    raise "Invalid timeout #{timeout}" unless timeout.is_a?(Numeric)

    unless destination.is_a?(String) || destination.is_a?(URI)
      raise "Invalid destination #{destination}"
    end

    # URI.join doesn't allow for http://localhost:8081/#/ as a base_url
    # so this departs from the Protractor behavior and favors File.join instead.
    #
    # In protractor: url.resolve('http://localhost:8081/#/', 'async')
    #                => http://localhost:8081/async
    # In Ruby:       File.join('http://localhost:8081/#/', 'async')
    #                => http://localhost:8081/#/async
    #
    base_url_exists = base_url && !base_url.empty?
    tmp_uri = URI.parse(destination) rescue URI.parse('')
    relative_url = !tmp_uri.scheme || !tmp_uri.host

    if base_url_exists && relative_url
      destination = File.join(base_url, destination.to_s)
    elsif relative_url # prepend 'http://' to urls such as localhost
      destination = "http://#{destination}"
    end

    msg = lambda { |str| 'Protractor.get(' + destination + ') - ' + str }

    return driver_get(destination) if ignore_sync

    driver_get(reset_url)
    executeScript_(
      'window.location.replace("' + destination + '");',
      msg.call('reset url'))

    wait(timeout) do
      url                  = executeScript_('return window.location.href;', msg.call('get url'))
      not_on_reset_url     = url != reset_url
      destination_is_reset = destination == reset_url
      raise 'still on reset url' unless not_on_reset_url || destination_is_reset
    end

    # now that the url has changed, make sure Angular has loaded
    # note that the mock module logic is omitted.
    #
    waitForAngular description: 'Protractor.get', timeout: timeout
  end

  # Invokes the underlying driver.get. Does not wait for angular.
  # Does not use base_url or reset_url logic.
  #
  def driver_get url
    driver.bridge.driver_get url
  end

  #  @see webdriver.WebDriver.refresh
  #
  #  Makes a full reload of the current page. Assumes that the page being loaded uses Angular.
  #  If you need to access a page which does not have Angular on load, use
  #  driver_get.
  #
  #  @param opt_timeout [Integer] Number of seconds to wait for Angular to start.
  #
  def refresh opt_timeout
    timeout = opt_timeout || 10

    return driver.navigate.refresh if ignore_sync

    executeScript_('return window.location.href;',
                   'Protractor.refresh() - getUrl')

    get(href, timeout)
  end

  #  Browse to another page using in-page navigation.
  #  Assumes that the page being loaded uses Angular.
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
                     'Protractor.setLocation()', root_element, url)
    rescue Exception => e
      raise e.class, "Error while navigating to '#{url}' : #{e}"
    end
  end

  #  Returns the current absolute url from AngularJS.
  #  Waits for Angular.
  #
  #  @example
  #  browser.get('http://angular.github.io/protractor/#/api');
  #  expect(browser.getLocationAbsUrl())
  #      .toBe('/api');
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
  # @option opts [Watir::Browser] :watir the watir instance used for automation
  # @option opts [String]  :root_element the root element on which to find Angular
  # @option opts [Boolean] :ignore_sync if true, Protractor won't auto sync the page
  #
  def initialize opts={}
    @watir = opts[:watir]

    valid_watir = defined?(Watir::Browser) && @watir.is_a?(Watir::Browser)
    raise "Driver must be a Watir::Browser not #{@driver.class}" unless valid_watir
    @driver = @watir.driver

    unless Selenium::WebDriver::SearchContext::FINDERS.keys.include?(NEW_FINDERS_KEYS)
      Selenium::WebDriver::SearchContext::FINDERS.merge!(NEW_FINDERS_HASH)
    end

    unless Watir::ElementLocator::WD_FINDERS.include? NEW_FINDERS_KEYS
      old = Watir::ElementLocator::WD_FINDERS
      # avoid const redefinition warning
      Watir::ElementLocator.send :remove_const, :WD_FINDERS
      Watir::ElementLocator.send :const_set, :WD_FINDERS, old + NEW_FINDERS_KEYS
    end

    @driver.protractor = self

    # The css selector for an element on which to find Angular. This is usually
    # 'body' but if your ng-app is on a subsection of the page it may be
    # a subelement.
    #
    # @return [String]
    #
    @root_element      = opts.fetch :root_element, 'body'

    # If true, Protractor will not attempt to synchronize with the page before
    # performing actions. This can be harmful because Protractor will not wait
    # until $timeouts and $http calls have been processed, which can cause
    # tests to become flaky. This should be used only when necessary, such as
    # when a page continuously polls an API using $timeout.
    #
    # @return [Boolean]
    #
    @ignore_sync       = !!opts.fetch(:ignore_sync, false)

    @client_side_scripts = ClientSideScripts

    browser_name = driver.capabilities[:browser_name].to_s.strip
    @reset_url   = reset_url_for_browser browser_name

    @base_url          = opts.fetch(:base_url, nil)

    # must be local var for use with define element below.
    protractor_element = AngularWebdriver::ProtractorElement.new @watir

    # Top level element method to enable protractor syntax.
    # redefine element to point to the new protractor element instance.
    #
    # toplevel self enables by/element from within pry. rspec helpers enables
    # by/element within rspec tests when used with install_rspec_helpers.
    [eval('self', TOPLEVEL_BINDING), AngularWebdriver::RSpecHelpers].each do |obj|
      obj.send :define_singleton_method, :element do |*args|
        protractor_element.element *args
      end

      obj.send :define_singleton_method, :by do
        AngularWebdriver::By
      end
    end

    self
  end

  # Reset URL used on IE & Safari since they don't work well with data URLs
  ABOUT_BLANK       = 'about:blank'.freeze

  # Reset URL used by non-IE/Safari browsers
  DEFAULT_RESET_URL = 'data:text/html,<html></html>'.freeze

  # IE and Safari require about:blank because they don't work well with
  # data urls (flaky). For other browsers, data urls are stable.
  #
  # browser_name [String] the browser name from driver caps. Must be 'safari'
  #                       or 'internet explorer'
  # @return reset_url [String] the reset URL
  #
  def reset_url_for_browser browser_name
    if ['internet explorer', 'safari'].include?(browser_name)
      ABOUT_BLANK
    else
      DEFAULT_RESET_URL
    end
  end

  # @private
  #
  # Syncs the webdriver command if it's white listed
  #
  # @param webdriver_command [Symbol] the webdriver command to check for syncing
  #
  def sync webdriver_command
    return unless webdriver_command
    webdriver_command = webdriver_command.intern
    # Note get must not sync here because the get command is redirected to
    # protractor.get which already has the sync logic built in.
    #
    # also don't sync set location (protractor custom command already waits
    # for angular). the selenium set location is for latitude/longitude/altitude
    # and that doesn't require syncing
    #
    sync_whitelist    = %i(
      getCurrentUrl
      refresh
      getPageSource
      getTitle
      findElement
      findElements
      findChildElement
      findChildElements
    )
    must_sync         = sync_whitelist.include? webdriver_command

    waitForAngular if must_sync
  end

  # Instruct webdriver to wait until Angular has finished rendering and has
  # no outstanding $http or $timeout calls before continuing.
  # Note that Protractor automatically applies this command before every
  # WebDriver action.
  #
  # Will wait up to driver.max_wait_seconds (set with driver.set_max_wait)
  #
  # @param [Hash] opts
  # @option opts [String] :description An optional description to be added
  #                                    to webdriver logs.
  # @option opts [Integer] :timeout Amount of time in seconds to wait for
  #                                 angular to load. Default driver.max_wait_seconds
  # @return [WebDriver::Element, Integer, Float, Boolean, NilClass, String, Array]
  #
  def waitForAngular opts={} # Protractor.prototype.waitForAngular
    return if ignore_sync

    description = opts.fetch(:description, '')
    timeout     = opts.fetch(:timeout, driver.max_wait_seconds)

    wait(timeout: timeout, bubble: true) do
      begin
        # the client side script will return a string on error
        # the string won't be raised as an error unless we explicitly do so here
        error = executeAsyncScript_(client_side_scripts.wait_for_angular,
                                    "Protractor.waitForAngular() #{description}",
                                    root_element)
        raise Selenium::WebDriver::Error::JavascriptError, error if error
      rescue Exception => e
        # https://github.com/angular/protractor/blob/master/docs/faq.md
        raise e.class, "Error while waiting for Protractor to sync with the page: #{e}"
      end
    end
  end

  # Ensure description is exactly one line that ends in a newline
  # must use /* */ not // due to some browsers having problems
  # with // comments when used with execute script
  #
  def _js_comment description
    description = description ? '/* ' + description.gsub(/\s+/, ' ').strip + ' */' : ''
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
  #
  def executeAsyncScript_ script, description, *args
    # add description as comment to script so it shows up in server logs
    script = _js_comment(description) + script

    driver.execute_async_script script, *args
  end

  #  The same as {@code webdriver.WebDriver.prototype.executeScript},
  #  but with a customized description for debugging.
  #
  #  @private
  #  @param script [String] The javascript to execute.
  #  @param description [String]  A description of the command for debugging.
  #  @param args [var_args] The arguments to pass to the script.
  #  @return The scripts return value.
  #
  def executeScript_ script, description, *args
    # add description as comment to script so it shows up in server logs
    script = _js_comment(description) + script

    driver.execute_script script, *args
  end

  # Injects client side scripts into window.clientSideScripts for debugging.
  #
  # Example:
  #
  # ```ruby
  # # inject the scripts
  # protractor.debugger
  #
  # # now that the scripts are injected, they can be used via execute_script
  # driver.execute_script "window.clientSideScripts.getLocationAbsUrl('body')"
  # ```
  #
  # This should be used under Pry. The window client side scripts can be
  # invoked using chrome dev tools after calling debugger.
  #
  def debugger
    executeScript_ client_side_scripts.install_in_browser, 'Protractor.debugger()'
  end

  # Determine if animation is allowed on the current underlying elements.
  # @param <Element> web_element - the web element to act upon
  # @param <Boolean> value - turn on/off ng-animate animations.
  #
  # @example
  # // Turns off ng-animate animations for all elements in the <body>
  # element(by.css('body')).allowAnimations(false);
  #
  # @return <Boolean> whether animation is allowed.
  def allowAnimations web_element, value=nil
    executeScript_ client_side_scripts.allow_animations, 'Protractor.allow_animations()', web_element, value
  end

  # Evaluate an Angular expression as if it were on the scope
  # of the given element.
  #
  # @param element <Element> The element in whose scope to evaluate.
  # @param expression <String> The expression to evaluate.
  #
  # @return <Object> The result of the evaluation.
  def evaluate element, expression
    # angular.element(element).scope().$eval(expression);
    executeScript_ client_side_scripts.evaluate, 'Protractor.evaluate()', element, expression
  end

  private

  # @private
  # Internal function only useful as part of Protractor's custom get logic
  # which pauses then resumes the bootstrap. Currently not used at all.
  #
  # Do not use!
  def testForAngular timeout_seconds=10
    # [false, "retries looking for angular exceeded"]
    # [false, "angular never provided resumeBootstrap"]
    executeAsyncScript_ client_side_scripts.test_for_angular, 'Protractor.testForAngular', timeout_seconds
  end
end
