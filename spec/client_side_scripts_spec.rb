require_relative 'spec_helper'

describe 'client side scripts' do

  it 'matches the methods and content of clientSideScripts.json' do
    expected = symbolize_keys JSON.parse File.read File.join __dir__, '../gen/clientSideScripts.json'
    actual   = ClientSideScripts.scripts

    # actual must be identical to expected.
    # make sure to regenerate both json and the ruby code (thor gen) before testing
    expect(actual).to eq(expected)

    # verify individual methods return the expected results.
    ClientSideScripts.singleton_methods(false).each do |method_name|
      # scripts helper is only for Ruby so skip it
      skip_methods = %i(scripts)
      next if skip_methods.include?(method_name)

      camel_case = method_name.to_s.gsub(/([a-z\d])_([a-z])/) do
        full, one, two = Regexp.last_match.to_a
        "#{one}#{two.upcase}"
      end.intern

      expect(ClientSideScripts.send(method_name)).to eq(expected[camel_case])
    end
  end
end
