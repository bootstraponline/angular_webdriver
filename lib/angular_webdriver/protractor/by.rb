module AngularWebdriver
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

      # Find an element by exact binding.
      #
      # @view
      # <span>{{ person.name }}</span>
      # <span ng-bind="person-email"></span>
      # <span>{{person_phone|uppercase}}</span>
      #
      # @example
      # expect(element(by.exactBinding('person.name')).present?).to eq(true);
      # expect(element(by.exactBinding('person-email')).present?).to eq(true);
      # expect(element(by.exactBinding('person')).present?).to eq(false);
      # expect(element(by.exactBinding('person_phone')).present?).to eq(true);
      # expect(element(by.exactBinding('person_phone|uppercase')).present?).to eq(true);
      # expect(element(by.exactBinding('phone')).present?).to eq(false);
      #
      #  @param binding_descriptor <String>
      #  @return { exactBinding: binding_descriptor }
      def exactBinding binding_descriptor
        { exactBinding: binding_descriptor }
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

      #  Find elements inside an ng-repeat.
      #
      #  @view
      #  <div ng-repeat="cat in pets">
      #    <span>{{cat.name}}</span>
      #    <span>{{cat.age}}</span>
      #  </div>
      #
      #  <div class="book-img" ng-repeat-start="book in library">
      #    <span>{{$index}}</span>
      #  </div>
      #  <div class="book-info" ng-repeat-end>
      #    <h4>{{book.name}}</h4>
      #    <p>{{book.blurb}}</p>
      #  </div>
      #
      #  @example
      #  // Returns the DIV for the second cat.
      #  secondCat = element(by.repeater('cat in pets').row(1));
      #
      #  // Returns the SPAN for the first cat's name.
      #  firstCatName = element(by.repeater('cat in pets').
      #      row(0).column('cat.name'));
      #
      #  // Returns a promise that resolves to an array of WebElements from a column
      #  ages = element.all(
      #      by.repeater('cat in pets').column('cat.age'));
      #
      #  // Returns a promise that resolves to an array of WebElements containing
      #  // all top level elements repeated by the repeater. For 2 pets rows resolves
      #  // to an array of 2 elements.
      #  rows = element.all(by.repeater('cat in pets'));
      #
      #  // Returns a promise that resolves to an array of WebElements containing all
      #  // the elements with a binding to the book's name.
      #  divs = element.all(by.repeater('book in library').column('book.name'));
      #
      #  // Returns a promise that resolves to an array of WebElements containing
      #  // the DIVs for the second book.
      #  bookInfo = element.all(by.repeater('book in library').row(1));
      #
      #  // Returns the H4 for the first book's name.
      #  firstBookName = element(by.repeater('book in library').
      #      row(0).column('book.name'));
      #
      #  // Returns a promise that resolves to an array of WebElements containing
      #  // all top level elements repeated by the repeater. For 2 books divs
      #  // resolves to an array of 4 elements.
      #  divs = element.all(by.repeater('book in library'));
      #
      #  @param {string} repeatDescriptor
      #  @return {{findElementsOverride: findElementsOverride, toString: Function|string}}
      #
      def repeater repeat_descriptor
        ByRepeaterInner.new exact: false, repeat_descriptor: repeat_descriptor
      end

      # Find an element by exact repeater.
      #
      #  @view
      #  <li ng-repeat="person in peopleWithRedHair"></li>
      #  <li ng-repeat="car in cars | orderBy:year"></li>
      #
      #  @example
      #  expect(element(by.exactRepeater('person in peopleWithRedHair')).present?)
      #      .to eq(true);
      #  expect(element(by.exactRepeater('person in people')).present?).to eq(false);
      #  expect(element(by.exactRepeater('car in cars')).present?).to eq(true);
      #
      #  @param {string} repeatDescriptor
      #  @return {{findElementsOverride: findElementsOverride, toString: Function|string}}
      #
      def exactRepeater repeat_descriptor
        ByRepeaterInner.new exact: true, repeat_descriptor: repeat_descriptor
      end

      # Find an element by css selector within the Shadow DOM.
      #
      # @alias by.deepCss(selector)
      # @view
      # <div>
      #   <span id="outerspan">
      #   <"shadow tree">
      #     <span id="span1"></span>
      #     <"shadow tree">
      #       <span id="span2"></span>
      #     </>
      #   </>
      # </div>
      # @example
      # spans = element.all(by.deepCss('span'));
      # expect(spans.count()).to eq(3);
      def deepCss selector
        # TODO: syntax will change from /deep/ to >>> at some point.
        { css: '* /deep/ ' + selector }
      end
    end # class << self
  end # class By
end # module AngularWebdriver

def by
  AngularWebdriver::By
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
 :xpath=>"xpath"}
=end
