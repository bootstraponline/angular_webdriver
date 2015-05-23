# https://github.com/angular/protractor/blob/6ebc4c3f8b557a56e53e0a1622d1b44b59f5bc04/spec/basic/actions_spec.js
require_relative '../../../spec/spec_helper'

describe 'using an ActionSequence' do
  before(:each) { visit 'form' }

  it 'should drag and drop' do
    sliderBar = element(by.name('points'))

    expect(sliderBar.value).to eq('1')

    sliderBar.drag_and_drop_by(400, 20)

    expect(sliderBar.value).to eq('10')
  end
end
