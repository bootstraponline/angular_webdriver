class SpecHelpers

  def max_wait_seconds_default
    10
  end

  def max_page_wait_seconds_default
    30
  end

  # requires angular's test app to be running
  def angular_website
    'http://localhost:8081/#/'.freeze
  end

  def visit page=''
    driver.get angular_website + page
  end

  # Sets the driver's set_max_wait (client side client wait)
  def set_max_wait timeout_seconds
    driver.set_max_wait timeout_seconds
  end

  # driver.max_wait_seconds
  def max_wait_seconds
    driver.max_wait_seconds
  end

  # Sets the driver's set_max_page_wait (client side wait used in protractor.get)
  def set_max_page_wait timeout_seconds
    driver.set_max_page_wait timeout_seconds
  end

  # Returns driver.max_page_wait_seconds
  def max_page_wait_seconds
    driver.max_page_wait_seconds
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

  # Returns time in seconds it took for the block to execute.
  def time_seconds &block
    raise 'Must provide block to time_seconds' unless block
    start = Time.now
    block.call
    elapsed = Time.now - start
    elapsed.round
  end
end
