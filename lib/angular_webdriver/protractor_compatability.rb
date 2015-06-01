# see protractor_compatability_spec for example usage
# designed for use with watir-webdriver

# todo: avoid global browser / @browser
# todo: use module namespace for classes

class ProtractorElement
  attr_accessor :watir

  def initialize watir
    @watir = watir
  end

  # @return Watir::HTMLElementCollection
  def all *args
    watir.elements *args
  end
end

def protractor_element
  @pelement ||= ProtractorElement.new @browser
end

# @return Watir::HTMLElement
def element *args
  return protractor_element unless args.length > 0
  browser.element *args
end

class By
  class << self

    #
    # Selenium locators
    #

    def class what
      { class: what }
    end

    def class_name what
      { class_name: what }
    end

    def css what
      { css: what }
    end

    def id what
      { id: what }
    end

    def link what
      { link: what }
    end

    def link_text what
      { link_text: what }
    end

    def name what
      { name: what }
    end

    def partial_link_text what
      { partial_link_text: what }
    end

    def tag_name what
      { tag_name: what }
    end

    def xpath what
      { xpath: what }
    end

    #
    # Protractor locators
    # See protractor/lib/locators.js
    #

    #  Find an element by binding. Does a partial match, so any elements bound to
    #  variables containing the input string will be returned.
    #
    #  Note: For AngularJS version 1.2, the interpolation brackets, usually {{}},
    #  are allowed in the binding description string. For Angular version 1.3, they
    #  are not allowed, and no elements will be found if they are used.
    #
    #  @view
    #  <span>{{person.name}}</span>
    #  <span ng-bind="person.email"></span>
    #
    #  @example
    #  span1 = element(by.binding('person.name'))
    #  expect(span1.text).to eq('Foo')
    #
    #  span2 = element(by.binding('person.email'))
    #  expect(span2.text.to eq('foo@bar.com')
    #
    #  # You can also use a substring for a partial match
    #  span1alt = element(by.binding('name'))
    #  expect(span1alt.text).to eq('Foo')
    #
    #  # This works for sites using Angular 1.2 but NOT 1.3
    #  deprecatedSyntax = element(by.binding('{{person.name}}'))
    #
    #  @param binding_descriptor <String>
    #  @return { binding: binding_descriptor }
    def binding binding_descriptor
      { binding: binding_descriptor }
    end

    # Find a button by partial text.
    #
    # @view
    # <button>Save my file</button>
    #
    # @example
    # element(by.partialButtonText('Save'))
    #
    # @param search_text <String>
    # @return { partialButtonText: search_text }
    def partialButtonText search_text
      { partialButtonText: search_text }
    end

    # Find a button by text.
    #
    # @view
    # <button>Save</button>
    #
    # @example
    # element(by.buttonText('Save'))
    #
    # @param search_text <String>
    # @return {buttonText: search_text }
    def buttonText search_text
      { buttonText: search_text }
    end

    # Find an element by ng-model expression.
    #
    # @alias by.model(modelName)
    # @view
    # <input type="text" ng-model="person.name">
    #
    # @example
    # input = element(by.model('person.name'))
    # input.send_keys('123')
    # expect(input.value).to eq('Foo123')
    #
    # @param model_expression <String>  ng-model expression.
    # @return { model: model_expression }
    def model model_expression
      { model: model_expression }
    end

    #  Find an element by ng-options expression.
    #
    #  @alias by.options(optionsDescriptor)
    #  @view
    #  <select ng-model="color" ng-options="c for c in colors">
    #    <option value="0" selected="selected">red</option>
    #    <option value="1">green</option>
    #  </select>
    #
    #  @example
    #  allOptions = element.all(by.options('c for c in colors')).to_a
    #  expect(allOptions.length).to eq(2);
    #  firstOption = allOptions.first
    #  expect(firstOption.text).to eq('red')
    #
    #  @param options_descriptor <String> ng-options expression.
    #  @return { options: options_descriptor }
    def options options_descriptor
      { options: options_descriptor }
    end

    #  Find elements by CSS which contain a certain string.
    #
    #  @view
    #  <ul>
    #    <li class="pet">Dog</li>
    #    <li class="pet">Cat</li>
    #  </ul>
    #
    #  @example
    #  # Returns the li for the dog, but not cat.
    #  dog = element(by.cssContainingText('.pet', 'Dog'))
    # @return { cssContainingText: { cssSelector: css_selector, searchText: search_text } }
    def cssContainingText css_selector, search_text
      # the "what" must be a string or watir will complain it's not a valid what.
      # even if watir is patched to accept hashes, the what will be converted
      # to a string by the time it's seen by selenium webdriver.
      { cssContainingText: { cssSelector: css_selector, searchText: search_text }.to_json }
    end
  end
end

def by
  By
end

=begin
> Selenium::WebDriver::SearchContext::FINDERS
=> {:class=>"class name",
 :class_name=>"class name",
 :css=>"css selector",
 :id=>"id",
 :link=>"link text",
 :link_text=>"link text",
 :name=>"name",
 :partial_link_text=>"partial link text",
 :tag_name=>"tag name",
 :xpath=>"xpath",
 :binding=>"binding"}
=end
