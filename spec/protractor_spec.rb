require_relative 'spec_helper'

describe 'client side scripts' do

  before do
    # remote driver is useful for debugging
    # @driver = Selenium::WebDriver.for :remote, desired_capabilities: Selenium::WebDriver::Remote::Capabilities.firefox
    @driver = Selenium::WebDriver.for :firefox
    raise 'Driver is nil!' unless @driver

    # set script timeout for protractor client side javascript
    # https://github.com/angular/protractor/issues/117
    @driver.manage.timeouts.script_timeout = 60 # seconds

    @protractor = Protractor.new driver: @driver
  end

  # requires angular's test app to be running
  def angular_website
    'http://localhost:8081/#/'
  end

  def visit page
    @driver.get angular_website + page
    @protractor.waitForAngular
  end

  after do
    @driver.quit rescue nil
  end

  it 'finds by bindings' do
    visit 'async'

    eles   = @driver.find_elements(:binding, 'slowHttpStatus')
    result = eles.first.is_a? Selenium::WebDriver::Element
    expect(result).to eq(true)


    ele    = @driver.find_element(:binding, 'slowHttpStatus')
    result = ele.is_a? Selenium::WebDriver::Element
    expect(result).to eq(true)

    expect { @driver.find_element(:binding, "doesn't exist") }.to raise_error(Selenium::WebDriver::Error::NoSuchElementError)
  end

  it 'waitForAngular should error on non-angular pages' do
    error_class   = Selenium::WebDriver::Error::JavascriptError
    error_message = /angular could not be found on the window/
    expect { @protractor.waitForAngular }.to raise_error(error_class, error_message)
  end

  it 'waitForAngular should succeed on angular pages with wait' do
    @driver.get angular_website

    wait(timeout: 15) { @protractor.waitForAngular }
  end
end
