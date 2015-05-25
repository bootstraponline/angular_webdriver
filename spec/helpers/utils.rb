def wait_seconds_default
  10
end

def browser
  @browser
end

# requires angular's test app to be running
def angular_website
  'http://localhost:8081/#/'.freeze
end

def visit page=''
  driver.get angular_website + page
end

def protractor
  @protractor
end

def driver
  @driver
end

def no_wait &block
  driver.set_wait 0
  block.call
  driver.set_wait wait_seconds_default
end

# Sets the driver's set_wait (client side client wait)
def set_wait timeout_seconds
  driver.set_wait timeout_seconds
end

# Returns time in seconds it took for the block to execute.
def time_seconds &block
  start = Time.now
  block.call
  elapsed = Time.now - start
  elapsed.round
end

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
