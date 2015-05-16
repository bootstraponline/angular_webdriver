require_relative 'spec_helper'

describe 'client side scripts' do

  it 'matches the methods and content of clientSideScripts.json' do
    expected = symbolize_keys JSON.parse File.read File.join __dir__, '../lib/angular_webdriver/protractor/clientSideScripts.json'
    actual   = ClientSideScripts.client_side_scripts

    # actual must be identical to expected.
    # make sure to regenerate both json and the ruby code before testing
    expect(actual).to eq(expected)
  end
end
