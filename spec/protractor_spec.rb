require_relative 'spec_helper'

=begin
Each test runs in the same browser instance.
The test must initialize any required state at the start (it block)

After each test the page is reset and ignore_sync is set to false. (rspec before)


Protractor CLI

browser.get('http://localhost:8081/#/')
browser.setLocation('async')
.exit
=end

describe 'client side scripts' do

  before(:all) do
    # remote driver is useful for debugging
    # @driver = Selenium::WebDriver.for :remote, desired_capabilities: Selenium::WebDriver::Remote::Capabilities.firefox
    @driver = Selenium::WebDriver.for :firefox
    raise 'Driver is nil!' unless driver

    # Must activate protractor before any driver commands
    @protractor                           = Protractor.new driver: driver

    # set script timeout for protractor client side javascript
    # https://github.com/angular/protractor/issues/117
    driver.manage.timeouts.script_timeout = 60 # seconds
  end

  after(:all) do
    driver.quit rescue nil
  end

  before do
    protractor.ignore_sync = false
    protractor.driver_get protractor.reset_url
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

  it 'root_element' do
    expect(protractor.root_element).to eq('body')

    a_div                   = 'a.div'
    protractor.root_element = a_div
    expect(protractor.root_element).to eq(a_div)

    protractor.root_element = 'body'
    expect(protractor.root_element).to eq('body')
  end

  it 'get' do
    # should raise error when loading blank page and ignore sync is false
    expect { driver.get protractor.reset_url }.to raise_error(*angular_not_found_error)

    # should not raise error when loading blank page and ignore sync is true
    protractor.ignore_sync = true
    expect { driver.get protractor.reset_url }.to_not raise_error

  end

  it 'driver_get' do
    # should never raise error since driver_get will never sync
    # (even when ignore sync is false)
    expect { protractor.driver_get protractor.reset_url }.to_not raise_error
  end

  it 'refresh' do
    # should raise error when loading blank page and ignore sync is false
    expect { driver.navigate.refresh }.to raise_error(*angular_not_found_error)

    # should not raise error when loading blank page and ignore sync is true
    protractor.ignore_sync = true
    expect { driver.navigate.refresh }.to_not raise_error
  end

=begin
todo: write tests for:

initialize
sync
waitForAngular
_js_comment
executeAsyncScript_
executeScript_
debugger
driver
driver
root_element
ignore_sync
client_side_scripts
reset_url
reset_url
base_url
=end

  it 'setLocation' do
    visit 'async'

    protractor.setLocation 'polling'

    actual   = driver.current_url
    expected = 'http://localhost:8081/#/polling'

    expect(actual).to eq(expected)
  end

  it 'getLocationAbsUrl' do
    visit 'async'

    actual   = protractor.getLocationAbsUrl
    expected = '/async'

    expect(actual).to eq(expected)
  end

  it 'finds by bindings' do
    visit 'async'

    eles   = driver.find_elements(:binding, 'slowHttpStatus')
    result = eles.first.is_a? Selenium::WebDriver::Element
    expect(result).to eq(true)


    ele    = driver.find_element(:binding, 'slowHttpStatus')
    result = ele.is_a? Selenium::WebDriver::Element
    expect(result).to eq(true)

    expect { driver.find_element(:binding, "doesn't exist") }.to raise_error(Selenium::WebDriver::Error::NoSuchElementError)
  end

  it 'waitForAngular should error on non-angular pages' do
    # ignore sync is false and we're on the reset page
    expect { protractor.waitForAngular }.to raise_error(*angular_not_found_error)
  end

  it 'waitForAngular should succeed on angular pages with wait' do
    visit 'async'

    wait(timeout: 15) { protractor.waitForAngular }
  end
end
