class SpecHelpers
  def angular_not_found_error
    error_class   = Selenium::WebDriver::Error::JavascriptError
    error_message = /angular could not be found on the window/
    [error_class, error_message]
  end

  def no_such_element_error
    Selenium::WebDriver::Error::NoSuchElementError
  end
end
