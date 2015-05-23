require 'rubygems'
require 'watir-webdriver'
require 'pry'
require 'webdriver_utils'

require 'json'
require 'ostruct'

require_relative '../lib/angular_webdriver'
require_relative 'protractor_compatability'

# match protractor semantics
# unfortunately setting always locate doesn't always locate.
Watir.always_locate = true
require_relative 'watir_always_locate_patch'

# https://github.com/rails/docrails/blob/a3b1105ada3da64acfa3843b164b14b734456a50/activesupport/lib/active_support/core_ext/hash/keys.rb#L84
def symbolize_keys(hash)
  fail 'symbolize_keys requires a hash' unless hash.is_a? Hash
  result = {}
  hash.each do |key, value|
    key = key.to_sym rescue key # rubocop:disable Style/RescueModifier
    result[key] = value.is_a?(Hash) ? symbolize_keys(value) : value
  end
  result
end

# -- Trace
trace = false

if trace
  require 'trace_files'

  targets = Dir.glob(File.join(__dir__, '../lib/**/*.rb'))
  targets.map! { |t| File.expand_path t }
  puts "Tracing: #{targets}"

  TraceFiles.set trace: targets
end

RSpec.configure do |config|
  config.before(:all) do
    # remote driver is useful for debugging
    # @browser = Watir::Browser.new :remote, desired_capabilities: Selenium::WebDriver::Remote::Capabilities.firefox

    @browser = Watir::Browser.new :firefox
    @driver  = @browser.driver
    raise 'Driver is nil!' unless driver

    @driver.extend Selenium::WebDriver::DriverExtensions::HasTouchScreen
    @driver.extend Selenium::WebDriver::DriverExtensions::HasLocation

    # Must activate protractor before any driver commands
    @protractor                           = Protractor.new driver: driver

    # set script timeout for protractor client side javascript
    # https://github.com/angular/protractor/issues/117
    driver.manage.timeouts.script_timeout = 60 # seconds

    # sometimes elements just don't exist even though the page has loaded
    # and wait for angular has succeeded. in these situations, use implicit wait.
    driver.manage.timeouts.implicit_wait = implicit_wait_default # seconds
  end

  config.after(:all) do
    driver.quit rescue nil
  end
end

def implicit_wait_default
  10
end

def browser
  @browser
end

# requires angular's test app to be running
def angular_website
  'http://localhost:8081/#/'.freeze
end

def visit page=''
  driver.get angular_website + page
end

def protractor
  @protractor
end

def driver
  @driver
end

def angular_not_found_error
  error_class   = Selenium::WebDriver::Error::JavascriptError
  error_message = /angular could not be found on the window/
  [error_class, error_message]
end

def expect_equal actual, expected
  expect(actual).to eq(expected)
end

def expect_angular_not_found &block
  expect { block.call }.to raise_error(*angular_not_found_error)
end

def expect_no_error &block
  expect { block.call }.to_not raise_error
end

def no_such_element_error
  Selenium::WebDriver::Error::NoSuchElementError
end

# Sets implicit wait to 0 then expects on no_such_element_error and
# finally restores implicit wait to default
def expect_no_element_error &block
  driver.manage.timeouts.implicit_wait = 0
  expect { block.call }.to raise_error no_such_element_error
  driver.manage.timeouts.implicit_wait = implicit_wait_default
end

# Expects on no_such_element_error and does not modify implicit wait
def expect_no_element_error_nowait &block
  expect { block.call }.to raise_error no_such_element_error
end

# Sets the driver's implicit wait
def set_wait timeout_seconds
  driver.manage.timeouts.implicit_wait = timeout_seconds
end

# Expects block to raise error
def expect_error &block
  expect { block.call }.to raise_error
end

# Returns time in seconds it took for the block to execute.
def time_seconds &block
  start = Time.now
  block.call
  elapsed = Time.now - start
  elapsed.round
end
