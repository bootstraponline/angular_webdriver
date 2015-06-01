def expect_equal actual, expected
  expect(actual).to eq(expected)
end

def expect_angular_not_found &block
  expect { block.call }.to raise_error(*angular_not_found_error)
end

def expect_no_error &block
  expect { block.call }.to_not raise_error
end

# Sets client wait to 0 then expects on no_such_element_error and
# finally restores client wait to default
def expect_no_element_error &block
  driver.set_max_wait 0
  expect { block.call }.to raise_error no_such_element_error
  driver.set_max_wait max_wait_seconds_default
end

# Expects on no_such_element_error and does not modify client wait
def expect_no_element_error_nowait &block
  expect { block.call }.to raise_error no_such_element_error
end

# Expects block to raise error
def expect_error &block
  expect { block.call }.to raise_error
end
