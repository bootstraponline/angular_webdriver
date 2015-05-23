# https://github.com/angular/protractor/blob/8743d5cdf4c6b1337f5a4bd376336911cf62b856/spec/basic/synchronize_spec.js
require_relative '../../../spec/spec_helper'

describe 'synchronizing with slow pages' do
  before(:each) { visit 'async' }

  it 'waits for http calls' do
    status = element(by.binding('slowHttpStatus'))
    button = element(by.css('[ng-click="slowHttp()"]'))

    expect(status.text).to eq('not started')

    button.click

    expect(status.text).to eq('done')
  end

  it 'waits for long javascript execution' do
    status = element(by.binding('slowFunctionStatus'))
    button = element(by.css('[ng-click="slowFunction()"]'))

    expect(status.text).to eq('not started')

    button.click

    expect(status.text).to eq('done')
  end

  it 'DOES NOT wait for timeout' do
    status = element(by.binding('slowTimeoutStatus'))
    button = element(by.css('[ng-click="slowTimeout()"]'))

    expect(status.text).to eq('not started')

    button.click

    expect(status.text).to eq('pending...')
  end

  it 'waits for $timeout' do
    status = element(by.binding('slowAngularTimeoutStatus'))
    button = element(by.css('[ng-click="slowAngularTimeout()"]'))

    expect(status.text).to eq('not started')

    button.click

    expect(status.text).to eq('done')
  end

  it 'waits for $timeout then a promise' do
    status = element(by.binding(
          'slowAngularTimeoutPromiseStatus'))
    button = element(by.css(
          '[ng-click="slowAngularTimeoutPromise()"]'))

    expect(status.text).to eq('not started')

    button.click

    expect(status.text).to eq('done')
  end

  it 'waits for long http call then a promise' do
    status = element(by.binding('slowHttpPromiseStatus'))
    button = element(by.css('[ng-click="slowHttpPromise()"]'))

    expect(status.text).to eq('not started')

    button.click

    expect(status.text).to eq('done')
  end

  it 'waits for slow routing changes' do
    status = element(by.binding('routingChangeStatus'))
    button = element(by.css('[ng-click="routingChange()"]'))

    expect(status.text).to eq('not started')

    button.click

    expect(driver.page_source).to match('polling mechanism')
  end

  it 'waits for slow ng-include templates to load' do
    status = element(by.css('.included'))
    button = element(by.css('[ng-click="changeTemplateUrl()"]'))

    expect(status.text).to eq('fast template contents')

    button.click

    expect(status.text).to eq('slow template contents')
  end
end
