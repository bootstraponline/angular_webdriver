Due to protractors design (lazy loading of elements and always refinding elements)
there's no need for syncing after an element action. This is because every
element action causes the element to be refound which triggers wait for angular.

These are some notes about sync_after which ended up not being used.
Instead the protractor semantics are matched by adopting watir-webdriver.

```ruby
# do not use. will be removed
  def sync_after webdriver_command
    # https://github.com/angular/protractor/blob/8743d5cdf4c6b1337f5a4bd376336911cf62b856/lib/element.js#L5
    # var WEB_ELEMENT_FUNCTIONS
    #
    # 'click',        # :clickElement,
    # 'sendKeys',     # :sendKeysToElement, :sendKeysToActiveElement, :sendModifierKeyToActiveElement
    # 'getTagName',   # :getElementTagName
    # 'getCssValue',  # getElementValueOfCssProperty
    # 'getAttribute', # :getElementAttribute
    # 'getText',      # :getElementText
    # 'getSize',      # :getElementSize,
    # 'getLocation',  # :getElementLocation, :getElementLocationOnceScrolledIntoView
    # 'isEnabled',    # :isElementEnabled
    # 'isSelected',   # :isElementSelected
    # 'submit',       # :submitElement
    # 'clear',        # :clearElement
    # 'isDisplayed',  # :isElementDisplayed
    # 'getOuterHtml', -- JS binding exclusive. not available in Ruby bindings.
    # 'getInnerHtml', -- JS binding exclusive. not available in Ruby bindings.
    # 'getId',        # :describeElement
    # 'getRawId'];    # same as element.ref however in Ruby this is purely client side.


    # todo: audit all web element functions (protractor element.js)
    # so that the sync test can pass.
    # commdands.rb


    # todo: evaluate these
    # :getElementValue
    # :dragElement
    # :getActiveElement
    # elementEquals


  end
```