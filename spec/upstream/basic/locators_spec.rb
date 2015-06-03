# todo: finish porting tests from protractor/spec/basic/locators_spec.js
require_relative '../../../spec/spec_helper'

describe 'locators' do
  before do
    visit 'form'
  end

  describe 'by binding' do
    it 'should find an element by binding' do
      greeting = element(by.binding('greeting'))

      expect(greeting.text).to eq('Hiya')
    end

    # it 'should allow custom expectations to expect an element' do 
    # Not applicable to Ruby

    it 'should find a binding by partial match' do
      greeting = element(by.binding('greet'))

      expect(greeting.text).to eq('Hiya')
    end

    it 'should find exact match by exactBinding' do
      greeting = element(by.exactBinding('greeting'))

      expect(greeting.text).to eq('Hiya')
    end

    it 'should not find partial match by exactBinding' do
      greeting = element(by.exactBinding('greet'))

      expect(greeting.present?).to eq(false)
    end

    it 'should find an element by binding with ng-bind attribute' do
      name = element(by.binding('username'))

      expect(name.text).to eq('Anon')
    end

    it 'should find an element by binding with ng-bind-template attribute' do
      name = element(by.binding('nickname|uppercase'))

      expect(name.text).to eq('(ANNIE)')
    end
  end # describe 'by binding'

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
      name     = element(by.binding('username'))

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

  describe 'by css containing text' do
    it 'should find elements by css and partial text' do
      arr = element.all(by.cssContainingText('#animals ul .pet', 'dog')).to_a
      expect(arr.length).to eq(2)
      expect(arr[0].id).to eq('bigdog')
      expect(arr[1].id).to eq('smalldog')
    end

    it 'should find elements with text-transform style' do
      selector = '#transformedtext div'
      expect(element(by.cssContainingText(selector, 'Uppercase')).id).to eq('textuppercase')
      expect(element(by.cssContainingText(selector, 'Lowercase')).id).to eq('textlowercase')
      expect(element(by.cssContainingText(selector, 'capitalize')).id).to eq('textcapitalize')
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

  describe 'by repeater' do
    before do
      visit 'repeater'
    end

    it 'should find by partial match' do
      fullMatch = element(
        by.repeater('baz in days | filter:\'T\'').
          row(0).column('baz.initial'))
      expect(fullMatch.text).to eq('T')

      partialMatch = element(
        by.repeater('baz in days').row(0).column('b'))
      expect(partialMatch.text).to eq('T')

      partialRowMatch = element(
        by.repeater('baz in days').row(0))
      expect(partialRowMatch.text).to eq('T')
    end

    it 'should return all rows when unmodified' do
      all = element.all(by.repeater('allinfo in days'))
      arr = all.to_a
      expect(arr.length).to eq(5)
      expect(arr[0].text).to eq('M Monday')
      expect(arr[1].text).to eq('T Tuesday')
      expect(arr[2].text).to eq('W Wednesday')
    end


    it 'should return a single column' do
      initials = element.all(
        by.repeater('allinfo in days').
          column('initial'))
      arr      = initials.to_a
      expect(arr.length).to eq(5)
      expect(arr[0].text).to eq('M')
      expect(arr[1].text).to eq('T')
      expect(arr[2].text).to eq('W')

      names = element.all(
        by.repeater('allinfo in days').
          column('name'))
      arr   = names.to_a
      expect(arr.length).to eq(5)
      expect(arr[0].text).to eq('Monday')
      expect(arr[1].text).to eq('Tuesday')
      expect(arr[2].text).to eq('Wednesday')
    end

    it 'should allow chaining while returning a single column' do
      secondName = element(by.css('.allinfo')).element(
        by.repeater('allinfo in days').column('name').row(2))
      expect(secondName.text).to eq('Wednesday')
    end

    it 'should return a single row' do
      secondRow = element(by.repeater('allinfo in days').row(1))
      expect(secondRow.text).to eq('T Tuesday')
    end

    it 'should return an individual cell' do
      secondNameByRowFirst = element(
        by.repeater('allinfo in days').
          row(1).
          column('name'))

      secondNameByColumnFirst = element(
        by.repeater('allinfo in days').
          column('name').
          row(1))

      expect(secondNameByRowFirst.text).to eq('Tuesday')
      expect(secondNameByColumnFirst.text).to eq('Tuesday')
    end

    it 'should find a using data-ng-repeat' do
      byRow = element(by.repeater('day in days').row(2))
      expect(byRow.text).to eq('W')

      byCol = element(by.repeater('day in days').row(2).column('day'))
      expect(byCol.text).to eq('W')
    end

    it 'should find using ng:repeat' do
      byRow = element(by.repeater('bar in days').row(2))
      expect(byRow.text).to eq('W')

      byCol = element(by.repeater('bar in days').row(2).column('bar'))
      expect(byCol.text).to eq('W')
    end

    it 'should determine if repeater elements are present' do
      expect(element(by.repeater('allinfo in days').row(3)).present?).to eq(true)
      # There are only 5 rows, so the 6th row is not present.
      expect(element(by.repeater('allinfo in days').row(5)).present?).to eq(false)
    end

    it 'should have by.exactRepeater working' do
      expect(element(by.exactRepeater('day in d')).present?).to eq(false)
      expect(element(by.exactRepeater('day in days')).present?).to eq(true)
    end

    describe 'repeaters using ng-repeat-start and ng-repeat-end' do
      it 'should return all elements when unmodified' do
        all = element.all(by.repeater('bloop in days'))

        arr = all.to_a
        expect(arr.length).to eq(3 * 5)
        expect(arr[0].text).to eq('M')
        expect(arr[1].text).to eq('-')
        expect(arr[2].text).to eq('Monday')
        expect(arr[3].text).to eq('T')
        expect(arr[4].text).to eq('-')
        expect(arr[5].text).to eq('Tuesday')
      end

      it 'should return a group of elements for a row' do
        firstRow = element.all(by.repeater('bloop in days').row(0))

        arr = firstRow.to_a
        expect(arr.length).to eq(3)
        expect(arr[0].text).to eq('M')
        expect(arr[1].text).to eq('-')
        expect(arr[2].text).to eq('Monday')
      end

      it 'should return a group of elements for a column' do
        nameColumn = element.all(by.repeater('bloop in days').column('name'))

        arr = nameColumn.to_a
        expect(arr.length).to eq(5)
        expect(arr[0].text).to eq('Monday')
        expect(arr[1].text).to eq('Tuesday')
      end

      it 'should find an individual element' do
        firstInitial = element(by.repeater('bloop in days').row(0).column('bloop.initial'))

        expect(firstInitial.text).to eq('M')
      end
    end # describe 'repeaters using ng-repeat-start and ng-repeat-end'
  end # describe 'by repeater'
end
