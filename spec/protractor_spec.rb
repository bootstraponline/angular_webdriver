require_relative 'spec_helper'

describe 'client side scripts' do

  before do
    @driver     = Selenium::WebDriver.for :firefox

    # set script timeout for protractor client side javascript
    # https://github.com/angular/protractor/issues/117
    @driver.manage.timeouts.script_timeout = 60 # seconds

    @protractor = Protractor.new driver: @driver
  end

  after do
    @driver.quit
  end

  it 'waitForAngular should error on non-angular pages' do
    error_class   = Selenium::WebDriver::Error::JavascriptError
    error_message = /angular could not be found on the window/
    expect { @protractor.waitForAngular }.to raise_error(error_class, error_message)
  end

  it 'waitForAngular should succeed on angular pages' do
    @driver.get 'https://angularjs.org/' # 'http://localhost:8081/' # use protractor's testapp
    @protractor.waitForAngular
  end
end
