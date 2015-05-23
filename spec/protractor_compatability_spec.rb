require_relative 'spec_helper'

describe 'protractor_compatability' do
  before(:each) do
    protractor.ignore_sync = true
    visit 'async'
  end

  after(:all) do
    protractor.ignore_sync = false
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
  end
end
