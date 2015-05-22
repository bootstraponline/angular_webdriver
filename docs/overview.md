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
- **Protractor.debugger - Injects client side scripts into 
  window.clientSideScripts for debugging.
  
## Protractor Locators

Supported Protractor Locators. Note these work just like the standard locators.
You can find a single element (find_element), multiple elements (find_elements),
and the finders are chainable (finding elements from a parent element).

- **binding** - `driver.find_element(:binding, 'slowHttpStatus')`
  
Not yet supported locators:

- **findRepeaterRows**
- **findAllRepeaterRows**
- **findRepeaterElement**
- **findRepeaterColumn**
- **findByModel**
- **findByOptions**
- **findByButtonText**
- **findByPartialButtonText**
- **findByCssContainingText**

Not yet supported other methods:

- **testForAngular**
- **evaluate**
- **allowAnimations**
