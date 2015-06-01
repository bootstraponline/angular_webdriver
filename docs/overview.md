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
  
## Supported Protractor Locators
 
Note these work the same as standard locators.
You can find a single element (find_element), multiple elements (find_elements),
and the finders are chainable (finding elements from a parent element). The protractor syntax
(element/element.all) is also available as an alternative to find_element/find_elements.

Locator                     | Protractor                                       | WebDriver
                        --- |                                              --- | ---
**binding**                 | `element(by.binding('slowHttpStatus'))`          | `driver.find_element(:binding, 'slowHttpStatus')`  
**findByPartialButtonText** | `element.all(by.partialButtonText('text')).to_a` | `driver.find_elements(:findByPartialButtonText, 'slowHttpStatus')`

## Unsupported Protractor Locators

These locators are on the roadmap for implementation.

- **findRepeaterRows**
- **findAllRepeaterRows**
- **findRepeaterElement**
- **findRepeaterColumn**
- **findByModel**
- **findByOptions**
- **findByButtonText**
- **findByCssContainingText**

Not yet supported other methods:

- **evaluate**

## Waiting

Implicit waits are [unreliable](http://stackoverflow.com/questions/15164742/combining-implicit-wait-and-explicit-wait-together-results-in-unexpected-wait-ti#answer-15174978)
due to being baked into the remote driver. Waiting in angular_webdriver has been
reimplemented client side to avoid flakiness.
 
**driver.set_wait(5)** - wait up to 5 seconds for an exception to not be raised
                         when finding an element.
**driver.wait_seconds** - The current wait amount (default 0) in seconds.
