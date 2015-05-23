require_relative 'spec_helper'

describe 'protractor_compatability' do
  before(:each) do
    protractor.ignore_sync = true
    visit 'async'
  end

  after(:all) do
    protractor.ignore_sync = false
  end

  it 'present? works on elements that do not exist' do
    does_not_exist = element(by.binding('does not exist'))

    # save 10 seconds by setting implicit wait to 0 before searching for
    # an element we expect to not exist. see no_wait helper.
    no_wait { expect(does_not_exist.present?).to eq(false) }
  end

  it 'implicitly waits when using custom protractor locator' do
    # expect_no_element_error_nowait is used because it doesn't modify the wait
    # don't use expect_no_element_error. that will modify the wait.
    does_not_exist = by.binding('does not exist')

    set_wait 0
    time = time_seconds { expect_no_element_error_nowait { element(does_not_exist).visible? } }
    expect_equal time, 0

    # find by all returns [] when there are no matches.
    time = time_seconds { expect_no_error { element.all(does_not_exist).to_a } }
    expect_equal time, 0

    set_wait 3
    time = time_seconds { expect_no_element_error_nowait { element(does_not_exist).visible? } }
    expect_equal time, 3

    # find by all returns [] when there are no matches.
    time= time_seconds { expect_no_error { element.all(does_not_exist).to_a } }
    expect_equal time, 3

    # restore default implicit wait for use by remaining tests
    set_wait implicit_wait_default
  end

  describe 'element' do
    it 'finds single elements' do
      # find single element using protractor locator and regular locator
      expect(element(by.binding('slowHttpStatus')).visible?).to eq true
      expect(element(by.css('[ng-click="slowHttp()"]')).visible?).to eq true
    end

    it 'errors when finding an element that does not exist' do
      expect_no_element_error { element(by.binding('does not exist')).visible? }
      expect_no_element_error { element(by.css('does not exist')).visible? }
    end

    it 'chains successfully' do
      # watir syntax
      browser.element(:binding, 'ok').element(:binding, 'ok')
      browser.element(:binding, 'ok').elements(:binding, 'ok')

      # mixed syntax
      browser.element(by.binding('ok')).element(by.binding('ok'))
      browser.element(by.binding('ok')).elements(by.binding('ok'))

      # protractor syntax
      element(by.binding('ok')).element(by.binding('ok'))
      element(by.binding('ok')).all(by.binding('ok'))
    end
  end

  describe 'element.all' do
    it 'finds multiple elements' do
      # find multiple element using protractor locator and regular locator
      expect(element.all(by.binding('slowHttpStatus')).to_a.length).to eq 1
      expect(element.all(by.tag_name('div')).to_a.length).to eq 3
    end

    it 'returns an empty array when finding elements that do not exist' do
      expect_equal element.all(by.binding('does not exist')).to_a, []
      expect_equal element.all(by.css('does not exist')).to_a, []
    end

    it 'errors when chained' do
      # watir syntax
      expect_error { browser.elements(:binding, 'ok').elements(:binding, 'ok') }
      expect_error { browser.elements(:binding, 'ok').element(:binding, 'ok') }

      # mixed syntax
      expect_error { browser.elements(by.binding('ok')).elements(by.binding('ok')) }
      expect_error { browser.elements(by.binding('ok')).element(by.binding('ok')) }

      # protractor syntax
      expect_error { element.all(by.binding('ok')).all(by.binding('ok')) }
      expect_error { element.all(by.binding('ok')).element(by.binding('ok')) }
    end
  end
end
