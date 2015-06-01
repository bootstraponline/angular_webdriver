# todo: finish porting tests from protractor/spec/basic/locators_spec.js
require_relative '../../../spec/spec_helper'

describe 'locators' do
  before do
    visit 'form'
  end

  describe 'by partial button text' do
    it 'should find multiple buttons containing "text"' do
      arr = element.all(by.partialButtonText('text')).to_a
      expect(arr.length).to eq(4)
      expect(arr[0].id).to eq('exacttext')
      expect(arr[1].id).to eq('otherbutton')
      expect(arr[2].id).to eq('submitbutton')
      expect(arr[3].id).to eq('inputbutton')
    end
  end

  describe 'by button text' do
    it 'should find two button containing "Exact text"' do
      arr = element.all(by.buttonText('Exact text')).to_a
      expect_equal arr.length, 2
      expect_equal arr[0].id, 'exacttext'
      expect_equal arr[1].id, 'submitbutton'

    end

    it 'should not find any buttons containing "text"' do
      # we expect this not to find anything so temp set client max wait to 0
      arr = no_wait { element.all(by.buttonText('text')).to_a }
      expect_equal arr.length, 0
    end
  end
end
