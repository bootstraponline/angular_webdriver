# Overview

angular_webdriver is a Ruby wrapper for Protractor's client side JavaScript.

Features supported:

- **Auto synchronization feature** - Protractor automatically 
  runs the waitForAngular command before selected WebDriver actions.
  See [sync](sync.md) for details.
- **Protractor.root_element** -  The css selector for an element on which to find Angular.
- **Protractor.ignore_sync** - If true, Protractor will not attempt to synchronize with
  the page before performing actions.
- **Protractor.base_url** - When set driver.get will resolve relative urls
  against the base_url
- **Protractor.client_side_scripts** - All of protractor's client side scripts
  are available as strings
- **Protractor.reset_url** - driver.get will use an appropriate reset url when 
  synchronizing with the page
- **Protractor.get** - Navigate to the given destination. Assumes that the page
  being loaded uses Angular. driver.get uses protractor.get. Uses base_url,
  reset_url, and waits for angular to load.
- **Protractor.refresh** - Makes a full reload of the current page. Assumes
  that the page being loaded uses Angular.
- **Protractor.setLocation** - Browse to another page using in-page navigation.
  Assumes that the page being loaded uses Angular.
- **Protractor.getLocationAbsUrl** - Returns the current absolute url from
  AngularJS. Waits for angular.
- **Protractor.waitForAngular** - Waits for angular to finish loading.
- **Protractor.executeAsyncScript_** - Same as driver.execute_async_script
  but with comment for debugging.
- **Protractor.executeScript_** - Same as driver.execute_script but with
  comment for debugging.
- **Protractor.debugger** - Injects client side scripts into 
  window.clientSideScripts for debugging.
- **Protractor.allowAnimations** - Control if animation is allowed on
  the current underlying elements.
- **element.evaluate** - Evaluate an Angular expression as if it were on the scope
  of the given element.

## Protractor semantics
  
The `by` syntax, such as `by.binding`, lazily finds elements.
 
- `element(by.binding('slowHttpStatus'))` - This will not locate the element until
the element is used (such as calling .value or explicitly invoking .locate)
- `element.all(by.partialButtonText('text'))` - This will not locate the elements
until `.to_a` is invoked.

In addition to lazy locating, elements are always rediscovered. element.value
will always first find the element and then get the value. The reason elements
are rediscovered each time instead of cached is that Protrator relies on running
waitForAngular before certain webdriver commands. For elements, the sync behavior
is triggered when we find an element. If we didn't always rediscover elements then
the element.value method wouldn't trigger a waitForAngular call and the page 
could still be processing angular logic.
  
## Supported Protractor Locators
 
Note these work the same as standard locators.
You can find a single element (find_element), multiple elements (find_elements),
and the finders are chainable (finding elements from a parent element). The protractor syntax
(element/element.all) is also available as an alternative to find_element/find_elements.

Client side script          | Protractor                                       | WebDriver
                        --- |                                              --- | ---
**binding**                 | `element(by.binding('slowHttpStatus')).locate`   | `driver.find_element(:binding, 'slowHttpStatus')`  
**findByPartialButtonText** | `element.all(by.partialButtonText('text')).to_a` | `driver.find_elements(:findByPartialButtonText, 'slowHttpStatus')`
**findByButtonText**        | `element.all(by.buttonText('Exact text')).to_a`  | `driver.find_elements(:buttonText, 'Exact text')`
**findByModel**             | `element(by.model('username'))`                  | `driver.find_element(:model, 'username')`
**findByOptions**           | `element.all(by.options('fruit')).to_a`          | `driver.find_elements(:options, 'fruit')`
**findByCssContainingText** | `element.all(by.cssContainingText('#animals ul .pet', 'dog')).to_a` | `driver.find_elements(:cssContainingText, { cssSelector: '#animals ul .pet', searchText: 'dog' }.to_json)`
**findRepeaterRows**        | `element(by.repeater('baz in days').row(0))`     | -
**findAllRepeaterRows**     | `element(by.repeater('baz in days'));`           | -
**findRepeaterElement**     | `element(by.repeater('baz in days').row(0).column('b'))` | -
**findRepeaterColumn**      | `element(by.repeater('baz in days').column('b'))`        | -

## By locators

All the [Protractor by locators](http://angular.github.io/protractor/#/api?view=ProtractorBy) are supported.
Camel case (by.deepCss) and snake case (by.deep_css) are both supported.

- by.binding
- by.exactBinding
- by.partialButtonText
- by.buttonText
- by.model
- by.options
- by.cssContainingText
- by.repeater
- by.exactRepeater
- by.deepCss

## Waiting

Implicit waits are [unreliable](http://stackoverflow.com/questions/15164742/combining-implicit-wait-and-explicit-wait-together-results-in-unexpected-wait-ti#answer-15174978)
due to being baked into the remote driver. Waiting in angular_webdriver has been
reimplemented client side to avoid flakiness.
 
**driver.set_max_wait(5)** - wait up to 5 seconds for an exception to not be raised
                             when finding an element.
**driver.max_wait_seconds** - The max wait amount (default 0) in seconds.
