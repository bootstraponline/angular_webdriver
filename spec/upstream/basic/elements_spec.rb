# https://github.com/angular/protractor/blob/6ebc4c3f8b557a56e53e0a1622d1b44b59f5bc04/spec/basic/elements_spec.js
require_relative '../../../spec/spec_helper'

# todo: port remaining elements_spec tests

describe 'ElementFinder' do
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
end

describe 'evaluating statements' do
  it 'should evaluate statements in the context of an element' do
    visit 'form'
    checkboxElem = element(by.id('checkboxes'))

    expect(checkboxElem.evaluate('show')).to eq(true)
  end
end
