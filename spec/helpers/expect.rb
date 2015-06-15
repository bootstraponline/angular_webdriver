module ExpectHelpers
  def expect_equal actual, expected
    expect(actual).to eq(expected)
  end

  def expect_angular_not_found &block
    no_wait do # since we expect angular not found, don't wait for default 10s
      expect { block.call }.to raise_error(*angular_not_found_error)
    end
  end

  def expect_no_error &block
    expect { block.call }.to_not raise_error
  end

  # Sets client wait to 0 then expects on no_such_element_error and
  # finally restores client wait to default
  def expect_no_element_error &block
    no_wait do
      expect { block.call }.to raise_error no_such_element_error
    end
  end

  # Expects on no_such_element_error. The client wait is respected.
  # Compare to expect_no_element_error which sets wait to 0 before
  # invoking the block.
  def expect_no_element_error_with_wait &block
    expect { block.call }.to raise_error no_such_element_error
  end

  def expect_no_method_error &block
    expect { block.call }.to raise_error NoMethodError
  end

  def expect_javascript_error &block
    expect { block.call }.to raise_error Selenium::WebDriver::Error::JavascriptError
  end

  # Expects block to raise error
  #
  # Does **not** modify client wait.
  def expect_error error=Exception, &block
    expect { block.call }.to raise_error error
  end
end
