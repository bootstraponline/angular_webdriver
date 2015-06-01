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
end
