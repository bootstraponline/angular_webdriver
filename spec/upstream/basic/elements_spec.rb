# https://github.com/angular/protractor/blob/6ebc4c3f8b557a56e53e0a1622d1b44b59f5bc04/spec/basic/elements_spec.js
require_relative '../../../spec/spec_helper'

# todo: port remaining elements_spec tests

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

    byCss = by.css('body')
    byBinding = by.binding('greet')

    expect(element(byCss).locator).to eq(byCss)
    expect(element(byBinding).locator).to eq(byBinding)
  end
end

describe 'evaluating statements' do
  it 'should evaluate statements in the context of an element' do
    visit 'form'
    checkboxElem = element(by.id('checkboxes'))

    expect(checkboxElem.evaluate('show')).to eq(true)
  end
end
