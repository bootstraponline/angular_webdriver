require_relative 'spec_helper'

describe 'client side scripts' do

  before {
    @driver = Selenium::WebDriver.for :firefox
  }

  after {
    @driver.quit
  }

  it 'should wait for angular' do
    protractor = Protractor.new driver: @driver
    # binding.pry
    protractor.waitForAngular
  end
end
