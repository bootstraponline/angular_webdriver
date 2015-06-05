# https://github.com/angular/protractor/blob/6ebc4c3f8b557a56e53e0a1622d1b44b59f5bc04/spec/basic/elements_spec.js
require_relative '../../../spec/spec_helper'

describe 'ElementFinder' do

  before do
    protractor.driver_get protractor.reset_url
  end

  it 'should return the same result as browser.findElement' do
    visit 'form'
    nameByElement = element(by.binding('username'))

    expect(nameByElement.text()).to eq(
                                      driver.find_element(by.binding('username')).text);
  end

  it 'should wait to grab the WebElement until a method is called' do
    # These should throw no error before a page is loaded.
    usernameInput = element(by.model('username'))
    name          = element(by.binding('username'))

    visit 'form'

    expect(name.text).to eq('Anon')

    usernameInput.clear
    usernameInput.send_keys('Jane')
    expect(name.text).to eq('Jane')
  end

  # ruby bindings do not chain element actions.
  # element.clear.send_keys will always fail.
  #
  # it 'should chain element actions' do

  it 'chained call should wait to grab the WebElement until a method is called' do
    # These should throw no error before a page is loaded.
    reused = element(by.id('baz')).
      element(by.binding('item.reusedBinding'))

    visit 'conflict'

    expect(reused.text).to eq('Inner: inner')
    expect(reused.present?).to eq(true)
  end

  it 'should differentiate elements with the same binding by chaining' do
    visit 'conflict'

    outerReused = element(by.binding('item.reusedBinding'))
    innerReused = element(by.id('baz')).element(by.binding('item.reusedBinding'))

    expect(outerReused.text).to eq('Outer: outer')
    expect(innerReused.text).to eq('Inner: inner')
  end

  it 'should chain deeper than 2' do
    # These should throw no error before a page is loaded.
    reused = element(by.css('body')).element(by.id('baz')).
      element(by.binding('item.reusedBinding'))

    visit 'conflict'

    expect(reused.text).to eq('Inner: inner')
  end

  it 'should determine element presence properly with chaining' do
    # present doesn't chain in the Ruby bindings so this has been modified
    visit 'conflict'
    expect(element(by.id('baz')).
             element(by.binding('item.reusedBinding')).present?).
      to eq(true)

    no_wait do
      expect(element(by.id('baz')).
               element(by.binding('nopenopenope')).present?).
        to eq(false)
    end
  end

  it 'should export an isPresent helper' do
    visit 'form'

    expect(element(by.binding('greet')).present?).to eq(true)
    no_wait { expect(element(by.binding('nopenopenope')).present?).to eq(false) }
  end

  # catching errors in a callback is node.js specific
  #
  # it 'should allow handling errors'
  # it 'should allow handling chained errors'

  it 'isPresent() should not raise error on chained finders' do
    visit 'form'
    elmFinder = element(by.css('.nopenopenope')).element(by.binding('greet'))

    no_wait { expect(elmFinder.present?).to eq(false); }
  end

  it 'should export an allowAnimations helper' do
    visit 'animation'
    animationTop = element(by.id('animationTop'))
    toggledNode  = element(by.id('toggledNode'))

    expect(animationTop.allowAnimations).to eq(true)
    animationTop.allowAnimations(false)
    expect(animationTop.allowAnimations).to eq(false)

    expect(toggledNode.present?).to eq(true)
    element(by.id('checkbox')).click
    # save 10 seconds by setting client wait to 0 before searching for
    # an element we expect to not exist. see no_wait helper.
    no_wait { expect(toggledNode.present?).to eq(false) }
  end

  it 'should keep a reference to the original locator' do
    visit 'form'

    byCss     = by.css('body')
    byBinding = by.binding('greet')

    expect(element(byCss).locator).to eq(byCss)
    expect(element(byBinding).locator).to eq(byBinding)
  end

  # exception propagation is node.js specific
  #
  # it 'should propagate exceptions'
  #
  # infinite looping promises is thankfully node specific
  #
  # it 'should be returned from a helper without infinite loops'

  it 'should be usable in WebDriver functions via getWebElement' do
    # note that ruby doesn't need the getWebElement call thanks to the watir patching
    visit 'form'
    greeting = element(by.binding('greeting'))
    driver.execute_script(
      'arguments[0].scrollIntoView', greeting)
  end
end # describe 'ElementFinder'

# --

describe 'ElementArrayFinder' do

  it 'action should act on all elements' do
    visit('conflict')

    multiElement = element.all(by.binding('item.reusedBinding'))
    expect(multiElement.map &:text).to eq(['Outer: outer', 'Inner: inner'])
  end

  it 'click action should act on all elements' do
    checkboxesElms = element.all(by.css('#checkboxes input'))
    visit 'index.html'

    expect(checkboxesElms.map &:selected?).to eq([true, false, false, false])
    checkboxesElms.map &:click
    expect(checkboxesElms.map &:selected?).to eq([false, true, true, true])
  end

  it 'action should act on all elements selected by filter' do
    visit 'index.html'

    multiElement = element.all(by.css('#checkboxes input')).to_a.each_with_index do |elem, index|
      index == 2 || index == 3
    end
    multiElement.map &:click
    expect(element(by.css('#letterlist')).text).to eq('wx')
  end

  it 'filter should chain with index correctly' do
    visit 'index.html'

    elem = element.all(by.css('#checkboxes input')).to_a.each_with_index do |elem, index|
      index == 2 || index == 3
    end.last
    elem.click
    expect(element(by.css('#letterlist')).text).to eq('x')
  end

  it 'filter should work in page object' do
    visit('form')

    elements = element.all(by.css('#animals ul li')).select do |element|
      element.text == 'big dog'
    end

    expect(elements.length).to eq(1)
  end

  it 'should be able to get ElementFinder from filtered ElementArrayFinder' do
    visit('form')

    elements = element.all(by.css('#animals ul li')).select do |element|
      element.text.include? 'dog'
    end

    expect(elements.length).to eq(3)
    expect(elements[2].text).to eq('other dog')
  end

  it 'filter should be compoundable' do
    isDog    = lambda do |element|
      element.text.include? 'dog'
    end
    isBig    = lambda do |element|
      element.text.include? 'big'
    end

    visit('form')

    elements = element.all(by.css('#animals ul li')).select(&isDog).select(&isBig)

    expect(elements.length).to eq(1)
    expect(elements.first.text).to eq('big dog')
  end

  # it 'filter should work with reduce' do
  #   isDog = function(elem) {
  #     return elem.text.then(function(text) {
  #       return text.indexOf('dog') > -1
  #     end
  #   }
  #   visit('form')
  #   value = element.all(by.css('#animals ul li')).filter(isDog).
  #       reduce(function(currentValue, elem, index, elemArr) {
  #         return elem.text.then(function(text) {
  #           return currentValue + index + '/' + elemArr.length + ': ' + text + '\n'
  #         end
  #       }, '')
  # 
  #   expect(value).to eq('0/3: big dog\n' +
  #                         '1/3: small dog\n' +
  #                         '2/3: other dog\n')
  # end

  it 'should find multiple elements scoped properly with chaining' do
    visit('conflict')

    elems = element.all(by.binding('item')).to_a
    expect(elems.length).to eq(4)

    elems = element(by.id('baz')).all(by.binding('item')).to_a
    expect(elems.length).to eq(2)
  end

  # rspec spec/upstream/basic/elements_spec.rb -e 'should wait to grab multiple chained elements'
  it 'should wait to grab multiple chained elements' do
    # These should throw no error before a page is loaded.
    reused = element(by.id('baz')).all(by.binding('item'))

    visit('conflict')

    expect(reused.length).to eq(2)
    expect(reused.first.text).to eq('Inner: inner')
    expect(reused.last().text).to eq('Inner other: innerbarbaz')
  end

  it 'should wait to grab elements chained by index' do
    # Note Ruby will always immediately find the element once index is accessed
    # This differs from protractor which will wait to resolve the locator
    # until .length/.text/or some other method is invoked after index.
    visit('conflict')

    reused = element(by.id('baz')).all(by.binding('item'))
    first  = reused.first()
    second = reused[1]
    last   = reused.last()

    expect(reused.length).to eq(2)
    expect(first.text).to eq('Inner: inner')
    expect(second.text).to eq('Inner other: innerbarbaz')
    expect(last.text).to eq('Inner other: innerbarbaz')
  end

  it 'should count all elements' do
    visit('form')

    num = element.all(by.model('color')).to_a.length
    expect(num).to eq(3)

    # Should also work with promise expect unwrapping
    expect(element.all(by.model('color')).to_a.length).to eq(3)
  end

  it 'should return 0 when counting no elements' do
    visit('form')

    expect(element.all(by.binding('doesnotexist')).to_a.length).to eq(0)
  end

  it 'should return not present when an element disappears within an array' do
    visit('form')
    elements         = element.all(by.model('color')).to_a
    disappearingElem = elements[0]
    expect(disappearingElem.present?).to eq true
    visit('bindings')
    no_wait { expect(disappearingElem.present?).to eq false }
  end

  it 'should get an element from an array' do
    colorList = element.all(by.model('color'))

    visit('form')

    expect(colorList.first.value).to eq('blue')
    expect(colorList[1].value).to eq('green')
    expect(colorList[2].value).to eq('red')
  end

  it 'should get an element from an array using negative indices' do
    colorList = element.all(by.model('color'))

    visit('form')

    expect(colorList[-3].value).to eq('blue')
    expect(colorList[-2].value).to eq('green')
    expect(colorList[-1].value).to eq('red')
  end

  it 'should get the first element from an array' do
    colorList = element.all(by.model('color'))
    visit('form')

    expect(colorList.first.value).to eq('blue')
  end

  it 'should get the last element from an array' do
    colorList = element.all(by.model('color'))
    visit('form')

    expect(colorList.last().value).to eq('red')
  end

  it 'should perform an action on each element in an array' do
    colorList = element.all(by.model('color'))
    visit('form')

    colorList.each do |colorElement|
      expect(colorElement.text).not_to eq('purple')
    end
  end

  it 'should keep a reference to the array original locator' do
    byCss   = by.css('#animals ul li')
    byModel = by.model('color')
    visit('form')

    expect(element.all(byCss).locator()).to eq(byCss)
    expect(element.all(byModel).locator()).to eq(byModel)
  end

  it 'should map each element on array and with promises' do
    visit('form')

    labels = element.all(by.css('#animals ul li')).map.with_index do |elm, index|
      {
        index: index,
        text:  elm.text
      }
    end

    expect(labels).to eq([
                           { index: 0, text: 'big dog' },
                           { index: 1, text: 'small dog' },
                           { index: 2, text: 'other dog' },
                           { index: 3, text: 'big cat' },
                           { index: 4, text: 'small cat' }
                         ])
  end

  it 'should map and resolve multiple promises' do
    visit('form')
    labels = element.all(by.css('#animals ul li')).map do |elm|
      {
        text:  elm.text,
        inner: elm.inner_html
      }
    end

    def newExpected expectedLabel
      {
        text:  expectedLabel,
        inner: expectedLabel
      }
    end

    expect(labels).to eq([
                           newExpected('big dog'),
                           newExpected('small dog'),
                           newExpected('other dog'),
                           newExpected('big cat'),
                           newExpected('small cat')
                         ])
  end

  it 'should map each element from a literal and promise array' do
    visit('form')
    i      = 1
    labels = element.all(by.css('#animals ul li')).to_a.map do |elm|
      result = i
      i      += 1
      result
    end

    expect(labels).to eq([1, 2, 3, 4, 5])
  end

  it 'should filter elements' do
    visit('form')
    count = element.all(by.css('#animals ul li')).to_a.select do |elem|
      elem.text == 'big dog'
    end
    count = count.length

    expect(count).to eq(1)
  end

  it 'should reduce elements' do
    visit('form')

    value = element.all(by.css('#animals ul li'))

    value = value.map.with_index do |elem, index|
      "#{index}/#{value.length}: #{elem.text}"
    end.join('\n') + '\n'

    expect(value).to eq('0/5: big dog\n' +
                          '1/5: small dog\n' +
                          '2/5: other dog\n' +
                          '3/5: big cat\n' +
                          '4/5: small cat\n')
  end

  it 'should allow using protractor locator within map' do
    visit('repeater')

    expected = [
      { first: 'M', second: 'Monday' },
      { first: 'T', second: 'Tuesday' },
      { first: 'W', second: 'Wednesday' },
      { first: 'Th', second: 'Thursday' },
      { first: 'F', second: 'Friday' }]

    result = element.all(by.repeater('allinfo in days')).map do |el|
      {
        first:  el.element(by.binding('allinfo.initial')).text,
        second: el.element(by.binding('allinfo.name')).text
      }
    end

    expect(result).to eq(expected)
  end
end # describe ElementArrayFinder

describe 'evaluating statements' do
  before do
    visit('form')
  end

  it 'should evaluate statements in the context of an element' do
    checkboxElem = element(by.id('checkboxes'))

    # Ruby has no promise expectation.
    expect(checkboxElem.evaluate('show')).to eq(true)
  end
end

# Ruby has no shortcut css notation ($$ and $ are JS only)
#
# describe 'shortcut css notation' do
# it 'should grab by css'
# it 'should chain $$ with $' do
