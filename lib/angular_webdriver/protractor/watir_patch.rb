require 'watir-webdriver'
require 'watir-webdriver/elements/element'

require_relative 'protractor'

# match protractor semantics
# unfortunately setting always locate doesn't always locate.
Watir.always_locate = true

#
# This patch serves a few purposes. The first is matching Protractor semantics
# of lazy finding elements and always relocating elements (ex: element.text)
#
# The second is removing unnecessary bloatware from Watir which has a number
# of checks that don't make sense for angular.js testing. The specifics
# of this patch will change in the next Watir release. Currently version
# 0.7.0 is targeted.
#
# The third is teaching Watir about angular specific locators
#
# Design goal: element.all(by.binding('slowHttpStatus'))
#              should not make any server requests
#

module Watir
  module Container
    #
    # Alias of elements for Protractor
    #

    def all(*args)
      elements(*args)
    end
  end # module Container

  #
  # Base class for HTML elements.
  #

  # Note the element class is different on master.

  class Element
    # Ensure that the element exists by always relocating it
    def assert_exists
      @element = locate
    end

    def assert_not_stale
      nil
    end

    def assert_enabled
      nil
    end

    # avoid context lookup
    def locate
      locator_class.new(@parent.wd, @selector, self.class.attribute_list).locate
    end

    # Invoke protractor.allowAnimations with freshly located element and
    # optional value.
    def allowAnimations value=nil
      assert_exists
      driver.protractor.allowAnimations @element, value
    end

    # Evaluate an Angular expression as if it were on the scope
    # of the current element.
    #
    # @param expression <String> The expression to evaluate.
    #
    # @return <Object> The result of the evaluation.
    def evaluate expression
      assert_exists
      driver.protractor.evaluate @element, expression
    end

    #
    # Returns true if the element exists and is visible on the page.
    #
    # @return [Boolean]
    # @see Watir::Wait
    #
    #
    # rescue element not found
    def present?
      exists? && visible?
    rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::StaleElementReferenceError, UnknownObjectException
      # if the element disappears between the exists? and visible? calls,
      # consider it not present.
      false
    end
  end


  #
  # The main class through which you control the browser.
  #

  class Browser
    def assert_exists
      # remove expensive window check
      raise Exception::Error, 'browser was closed' if @closed
    end

    def inspect
      nil # avoid expensive browser url and title lookup
    end
  end

  class ElementLocator
    def validate_element(element)
      tn = @selector[:tag_name]
      return element unless tn # don't validate nil tag names
      element_tag_name = element.tag_name.downcase

      return if tn && !tag_name_matches?(element_tag_name, tn)

      if element_tag_name == 'input'
        return if @selector[:type] && @selector[:type] != element.attribute(:type)
      end

      element
    end

    # always raise element not found / stale reference error
    def locate
      # element.all(by.partialButtonText('text')).to_a[0].value creates the
      # selector {:element=>#<Selenium::WebDriver::Element ...>}
      # in that case we've already located the element.
      #
      # see 'should find multiple buttons containing "text"' in locators_spec.rb
      return @selector[:element] if @selector.is_a?(Hash) && @selector[:element].is_a?(Selenium::WebDriver::Element)

      e = by_id and return e # short-circuit if :id is given

      if @selector.size == 1
        element = find_first_by_one
      else
        element = find_first_by_multiple
      end

      # This actually only applies when finding by xpath/css - browser.text_field(:xpath, "//input[@type='radio']")
      # We don't need to validate the element if we built the xpath ourselves.
      # It is also used to alter behavior of methods locating more than one type of element
      # (e.g. text_field locates both input and textarea)
      validate_element(element) if element
    end
  end
end
