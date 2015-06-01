# todo: finish porting tests from protractor/spec/basic/locators_spec.js
require_relative '../../../spec/spec_helper'

describe 'locators' do
  before do
    visit 'form'
  end


  describe 'by model' do
    it 'should find an element by text input model' do
      username = element(by.model('username'))
      name     = element(by.binding('username'))

      username.clear
      expect(name.text).to eq('')

      username.send_keys('Jane Doe')
      expect(name.text).to eq('Jane Doe')
    end

    it 'should find an element by checkbox input model' do
      expect(element(by.id('shower')).visible?).to eq(true)

      element(by.model('show')).click

      expect(element(by.id('shower')).visible?).to eq(false)
    end

    it 'should find a textarea by model' do
      about = element(by.model('aboutbox'))
      expect(about.value).to eq('This is a text box')

      about.clear
      about.send_keys('Something else to write about')

      expect(about.value).to eq('Something else to write about')
    end

    it 'should find multiple selects by model' do
      selects = element.all(by.model('dayColor.color')).to_a
      expect(selects.length).to eq(3)
    end

    it 'should find the selected option' do
      select         = element(by.model('fruit'))
      selectedOption = select.element(by.css('option:checked'))
      expect(selectedOption.text).to eq('apple')
    end

    it 'should find inputs with alternate attribute forms' do
      letterList = element(by.id('letterlist'))
      expect(letterList.text).to eq('')

      element(by.model('check.w')).click
      expect(letterList.text).to eq('w')

      element(by.model('check.x')).click
      expect(letterList.text).to eq('wx')
    end

    it 'should find multiple inputs' do
      arr = element.all(by.model('color')).to_a
      expect(arr.length).to eq(3)
    end

    it 'should clear text from an input model' do
      username = element(by.model('username'))
      name = element(by.binding('username'))

      username.clear
      expect(name.text).to eq('')

      username.send_keys('Jane Doe')
      expect(name.text).to eq('Jane Doe')

      username.clear
      expect(name.text).to eq('')
    end
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

  describe 'by options' do
    it 'should find elements by options' do
      allOptions = element.all(by.options('fruit for fruit in fruits')).to_a
      expect(allOptions.length).to eq(4)

      firstOption = allOptions.first
      expect(firstOption.text).to eq('apple')
    end
  end
end
