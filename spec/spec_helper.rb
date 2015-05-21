require 'rubygems'
require 'pry'
require 'webdriver_utils'
require 'json'
require 'ostruct'

require_relative '../lib/angular_webdriver'

# https://github.com/rails/docrails/blob/a3b1105ada3da64acfa3843b164b14b734456a50/activesupport/lib/active_support/core_ext/hash/keys.rb#L84
def symbolize_keys(hash)
  fail 'symbolize_keys requires a hash' unless hash.is_a? Hash
  result = {}
  hash.each do |key, value|
    key = key.to_sym rescue key # rubocop:disable Style/RescueModifier
    result[key] = value.is_a?(Hash) ? symbolize_keys(value) : value
  end
  result
end

# -- Trace

trace = false

if trace
  require 'trace_files'

  targets = Dir.glob(File.join(__dir__, '../lib/**/*.rb'))
  targets.map! { |t| File.expand_path t }
  puts "Tracing: #{targets}"

  TraceFiles.set trace: targets
end
