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

describe 'Protractor' do

  before(:each) do
    protractor.ignore_sync = false
    protractor.driver_get protractor.reset_url
    protractor.base_url = nil
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
    expect_angular_not_found { driver.get protractor.reset_url }

    # should not raise error when loading blank page and ignore sync is true
    protractor.ignore_sync = true
    expect_no_error { driver.get protractor.reset_url }
  end

  it 'driver_get' do
    # should never raise error since driver_get will never sync
    # (even when ignore sync is false)
    expect_no_error { protractor.driver_get protractor.reset_url }
  end

  it 'refresh' do
    # should raise error when loading blank page and ignore sync is false
    expect_angular_not_found { driver.navigate.refresh }

    # should not raise error when loading blank page and ignore sync is true
    protractor.ignore_sync = true
    expect_no_error { driver.navigate.refresh }
  end

  it 'ignore_sync' do
    protractor.ignore_sync = false
    expect(protractor.ignore_sync).to eq(false)
    expect_angular_not_found { driver.current_url }

    protractor.ignore_sync = true
    expect(protractor.ignore_sync).to eq(true)
    expect_no_error { driver.current_url }
  end

  it 'sync' do
    # :getCurrentUrl
    expect_angular_not_found { driver.current_url }
    # :refresh
    expect_angular_not_found { driver.navigate.refresh }
    # :getPageSource
    expect_angular_not_found { driver.page_source }
    # :getTitle
    expect_angular_not_found { driver.title }
    # :findElement
    expect_angular_not_found { driver.find_element(:tag_name, 'html') }
    # :findElements
    expect_angular_not_found { driver.find_elements(:tag_name, 'html') }
    # :findChildElement
    expect_angular_not_found { driver.find_element(:tag_name, 'html').find_element(:xpath, '//html') }
    # :findChildElements
    expect_angular_not_found { driver.find_element(:tag_name, 'html').find_elements(:xpath, '//html') }

    # doesn't raise error when sync is ignored
    protractor.ignore_sync = true
    # :getCurrentUrl
    expect_no_error { driver.current_url }
    # :refresh
    expect_no_error { driver.navigate.refresh }
    # :getPageSource
    expect_no_error { driver.page_source }
    # :getTitle
    expect_no_error { driver.title }
    # :findElement
    expect_no_error { driver.find_element(:tag_name, 'html') }
    # :findElements
    expect_no_error { driver.find_elements(:tag_name, 'html') }
    # :findChildElement
    expect_no_error { driver.find_element(:tag_name, 'html').find_element(:xpath, '//html') }
    # :findChildElements
    expect_no_error { driver.find_element(:tag_name, 'html').find_elements(:xpath, '//html') }
  end

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
    expect_angular_not_found { protractor.waitForAngular }
  end

  it 'waitForAngular should succeed on angular pages with wait' do
    visit 'async'

    wait(timeout: 15) { protractor.waitForAngular }
  end

  it '_js_comment' do
    comment  = " \n\n   Hello\n\r\nThere!\n  "
    actual   = protractor._js_comment comment
    expected = "/* Hello There! */\n"

    expect_equal actual, expected
  end

  def async_no_arg
    (<<-'JS').freeze
return (function (callback) {
  callback("hello");
})(arguments[0]);
    JS
  end

  def async_one_arg
    (<<-'JS').freeze
return (function (one, callback) {
  callback(one);
}).apply(this, arguments);;
    JS
  end

  def async_two_arg
    (<<-'JS').freeze
return (function (one, two, callback) {
  callback(one + two);
}).apply(this, arguments);;
    JS
  end

  it 'executeAsyncScript_' do
    actual   = protractor.executeAsyncScript_ async_no_arg, 'comment'
    expected = 'hello'
    expect_equal actual, expected

    actual   = protractor.executeAsyncScript_ async_one_arg, 'comment', 1
    expected = 1
    expect_equal actual, expected

    actual   = protractor.executeAsyncScript_ async_two_arg, 'comment', 1, 2
    expected = 3
    expect_equal actual, expected

    # the following two tests are copied from selenium ruby
    # https://github.com/SeleniumHQ/selenium/blob/ac2a47eb03e32e81c61db641e9a0ae3c4ebcc0fd/rb/spec/integration/selenium/webdriver/driver_spec.rb#L264
    actual   = protractor.executeAsyncScript_ "arguments[arguments.length - 1]([null, 123, 'abc', true, false]);", 'comment'
    expected = [nil, 123, 'abc', true, false]
    expect_equal actual, expected

    actual   = protractor.executeAsyncScript_ 'arguments[arguments.length - 1](arguments[0] + arguments[1]);', 'comment', 1, 2
    expected = 3
    expect_equal actual, expected
  end

  it 'executeScript_' do
    no_arg  = 'return "hello";'
    one_arg = 'return arguments[0];'
    two_arg = 'return arguments[0] + arguments[1];'

    actual   = protractor.executeScript_ no_arg, 'comment'
    expected = 'hello'
    expect_equal actual, expected

    actual   = protractor.executeScript_ one_arg, 'comment', 1
    expected = 1
    expect_equal actual, expected

    actual   = protractor.executeScript_ two_arg, 'comment', 1, 2
    expected = 3
    expect_equal actual, expected
  end

  it 'debugger' do
    protractor.debugger
    actual   = driver.execute_script "return typeof window.clientSideScripts === 'object'"
    expected = true
    expect_equal actual, expected
  end

  it 'driver' do
    protractor.ignore_sync = true

    # verify protractor driver method matches regular driver method
    actual                 = protractor.driver.current_url
    expected               = driver.current_url
    expect_equal actual, expected

    # verify we're on the correct url
    expected = protractor.reset_url
    expect_equal actual, expected
  end

  it 'reset_url' do
    actual   = protractor.reset_url
    expected = protractor.reset_url_for_browser driver.capabilities[:browser_name]
    expect_equal actual, expected
  end

  it 'reset_url_for_browser' do
    ['safari', 'internet explorer'].each do |browser|
      actual   = protractor.reset_url_for_browser browser
      expected = Protractor::ABOUT_BLANK
      expect_equal actual, expected
    end

    %w(firefox chrome).each do |browser|
      actual   = protractor.reset_url_for_browser browser
      expected = Protractor::DEFAULT_RESET_URL
      expect_equal actual, expected
    end
  end

  it 'client_side_scripts' do
    actual   = protractor.client_side_scripts
    expected = ::ClientSideScripts
    expect_equal actual, expected
  end

  it 'base_url' do
    expect(protractor.base_url).to eq(nil)

    protractor.base_url = angular_website
    expect(protractor.base_url).to eq(angular_website)

    # base url is automatically added to urls without a scheme
    protractor.get 'async'
    expect(driver.current_url).to eq('http://localhost:8081/#/async')

    # base url is not added to urls with a scheme
    protractor.get 'http://localhost:8081/#/polling'
    expect(driver.current_url).to eq('http://localhost:8081/#/polling')

    protractor.base_url = nil
    expect(protractor.base_url).to eq(nil)
  end

  #
  # note: allowAnimations is tested in upstream/basic/elements_spec
  #       'should export an allowAnimations helper'
  #

  it 'testForAngular' do
    # note this is a private method that is not and should not be used.
    # maybe one day it'll be useful in the custom get logic if
    # mocking support via injection is added.
    expected = [false, 'retries looking for angular exceeded']
    expect(protractor.send(:testForAngular, 1)).to eq(expected)
  end

  it 'adds protractor finders to webdriver and watir' do
    watir_finders            = Watir::ElementLocator::WD_FINDERS
    protractor_watir_finders = Protractor::NEW_FINDERS_KEYS

    protractor_watir_finders.each do |protractor_finder|
      watir_includes_protractor_finder = watir_finders.include? protractor_finder
      expect_equal watir_includes_protractor_finder, true
    end

    webdriver_finders            = Selenium::WebDriver::SearchContext::FINDERS
    protractor_webdriver_finders = Protractor::NEW_FINDERS_HASH

    protractor_webdriver_finders.keys.each do |key|
      expect_equal webdriver_finders[key], protractor_webdriver_finders[key]
    end
  end

  it 'watir valid whats are not modified' do
    expected_whats = [String, Regexp]
    actual_whats   = Watir::ElementLocator::VALID_WHATS
    expect_equal actual_whats, expected_whats
  end

  it 'gets attribute from element in watir element array' do
    visit 'async'
    expect_no_error { element.all(by.tag_name('html')).to_a[0].value }
  end

  it 'passes elements successfully to execute_script' do
    visit 'repeater'
    protractor.ignore_sync = true
    e                      = browser.element(tag_name: 'div')
    tag_name               = driver.execute_script 'return arguments[0].tagName', e
    tag_name.downcase!.strip!
    expect_equal tag_name, 'div'
  end

  it 'successfully converts selenium elements to json' do
    visit 'repeater'
    actual = element(by.css('.allinfo')).locate.to_json

    firefox_local = /{"ELEMENT":"{\h{8}-\h{4}-\h{4}-\h{4}-\h{12}}"/
    remote_driver = /{"ELEMENT":"\d+"/

    matched = !!(actual.match(firefox_local) || actual.match(remote_driver))
    expect_equal matched, true
  end

  it 'handles watir present and webdriver displayed' do
    protractor.ignore_sync = true

    # watir returns false on .present? when the element doesn't exist
    expect_equal browser.element(tag_name: 'html').present?, true
    no_wait { expect_equal browser.element(tag_name: 'doesntexist').present?, false }

    # webdriver throws element not found on .displayed? when the element doesn't exist
    expect_equal driver.find_element(tag_name: 'html').displayed?, true
    expect_no_element_error { driver.find_element(tag_name: 'doesntexist').displayed? }
  end
end
