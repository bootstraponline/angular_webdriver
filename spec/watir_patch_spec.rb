require_relative 'spec_helper'

describe 'watir_patch' do

  before(:each) { protractor.ignore_sync = false }

  it 'exists?' do
    visit 'async'

    no_wait { expect_equal element(by.css('does not exist')).exists?, false }

    expect_equal element(by.binding('slowHttpStatus')).exists?, true
  end

  it 'validate_element' do
    selector      = browser.input(id: 'testing').locator
    locator_class = ::Watir::ElementLocator

    locator = locator_class.new(browser, selector, ::Watir::Element.attribute_list)

    mock_element = Class.new do
      def tag_name
        'input'
      end

      def attribute type
        'random'
      end
    end.new

    locator.validate_element mock_element
  end

  it 'watir::browser' do
    browser.instance_variable_set(:@closed, true)
    expect_error { browser.assert_exists }

    browser.instance_variable_set(:@closed, false)
    expect_no_error { browser.assert_exists }
  end

  it 'locate find_first_by_multiple' do
    protractor.ignore_sync = true
    # finding with div xpath creates a selector of size 2
    # (one for tag_name div, the other for the xpath selector)
    # which is a different watir code path than normal.
    expect_no_error { browser.div(xpath: '//*').locate }
  end

  it 'does not prepend http:// to empty string' do
    protractor.base_url = angular_website
    protractor.get ''
    expect(driver.current_url).to eq('http://localhost:8081/#/form')
    protractor.base_url = nil
  end
end
