require 'rubygems'
require 'selenium-webdriver'
require 'selenium/webdriver/common/error'
require_relative 'webdriver_patch'

require_relative 'client_side_scripts'

class Protractor
  # code/comments from protractor/lib/protractor.js
  attr_accessor :root_element, :ignore_sync

  attr_reader :client_side_scripts, :driver

  def self.root_element
    @@root_element
  end

  def root_element
    @@root_element
  end

  # @param [Hash] opts the options to initialize with
  # @option opts [String]  :root_element the root element on which to find Angular
  # @option opts [Boolean] :ignore_sync if true, Protractor won't auto sync the page
  def initialize opts={}
    @driver = opts[:driver]
    raise 'Must supply Selenium::WebDriver' unless @driver

    watir = defined?(Watir::Browser) && @driver.is_a?(Watir::Browser)
    @driver = watir ? @driver.driver : @driver

    @driver.protractor = self

    # The css selector for an element on which to find Angular. This is usually
    # 'body' but if your ng-app is on a subsection of the page it may be
    # a subelement.
    #
    # @return [String]
    @@root_element = opts.fetch :root_element, 'body'

    # If true, Protractor will not attempt to synchronize with the page before
    # performing actions. This can be harmful because Protractor will not wait
    # until $timeouts and $http calls have been processed, which can cause
    # tests to become flaky. This should be used only when necessary, such as
    # when a page continuously polls an API using $timeout.
    #
    # @return [Boolean]
    @ignore_sync  = !!opts.fetch(:ignore_sync, false)

    @client_side_scripts = ClientSideScripts
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
      raise e.class, "Error while waiting for Protractor to sync with the page: #{e}"
    end
  end

  def executeAsyncScript_ script, description, args
    # ensure description is exactly one line that ends in a newline
    # must use /* */ not // due to some browsers having problems
    # with // comments when used with execute script
    description = description ? '/* ' + description.gsub(/\W+/, ' ') + ' */' : ''
    description = description.strip + "\n"

    # add description as comment to script so it shows up in server logs
    script      = description + script

    # puts "Evaluating:\n#{script}"

    driver.execute_async_script script, args
  end

=begin
  /**
 * Instruct webdriver to wait until Angular has finished rendering and has
 * no outstanding $http or $timeout calls before continuing.
 * Note that Protractor automatically applies this command before every
 * WebDriver action.
 *
 * @param {string=} opt_description An optional description to be added
 *     to webdriver logs.
 * @return {!webdriver.promise.Promise} A promise that will resolve to the
 *    scripts return value.
 */
Protractor.prototype.waitForAngular = function(opt_description) {
  var description = opt_description ? ' - ' + opt_description : '';
  if (this.ignoreSynchronization) {
    return webdriver.promise.fulfilled();
  }
  return this.executeAsyncScript_(
      clientSideScripts.waitForAngular,
      'Protractor.waitForAngular()' + description,
      this.rootEl).
      then(function(browserErr) {
        if (browserErr) {
          throw 'Error while waiting for Protractor to ' +
                'sync with the page: ' + JSON.stringify(browserErr);
        }
    }).then(null, function(err) {
      var timeout;
      if (/asynchronous script timeout/.test(err.message)) {
        // Timeout on Chrome
        timeout = /-?[\d\.]*\ seconds/.exec(err.message);
      } else if (/Timed out waiting for async script/.test(err.message)) {
        // Timeout on Firefox
        timeout = /-?[\d\.]*ms/.exec(err.message);
      } else if (/Timed out waiting for an asynchronous script/.test(err.message)) {
        // Timeout on Safari
        timeout = /-?[\d\.]*\ ms/.exec(err.message);
      }
      if (timeout) {
        throw 'Timed out waiting for Protractor to synchronize with ' +
            'the page after ' + timeout + '. Please see ' +
            'https://github.com/angular/protractor/blob/master/docs/faq.md';
      } else {
        throw err;
      }
    });
};
=end
end
