require_relative 'spec_helper'

describe 'watir_patch' do

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
end
