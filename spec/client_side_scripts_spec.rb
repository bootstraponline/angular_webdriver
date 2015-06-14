require_relative 'spec_helper'

describe 'client side scripts' do

  it 'matches the methods and content of clientSideScripts.json' do
    expected = symbolize_keys JSON.parse File.read File.join __dir__, '../gen/clientSideScripts.json'
    actual   = ClientSideScripts.scripts

    # actual must be identical to expected.
    # make sure to regenerate both json and the ruby code (thor gen) before testing
    expect(actual).to eq(expected)

    # verify individual methods return the expected results.
    ClientSideScripts.singleton_methods(false) do |method|
      expect(ClientSideScripts.send(method)).to eq(expected[method])
    end
  end
end
