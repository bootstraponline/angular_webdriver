# Sync

Protractor provides two methods to synchronize with AngularJS. The first is
`testForAngular`. `testForAngular` is exclusively used for protractor's custom
get method for pausing the angular bootstrap before injecting mocks then resuming
the bootstrap.

There are better ways to mock angular apps than injecting them via selenium tests.
The mock feature of Protractor is not planned to be implemented in angular_webdriver
unless a compelling use case is found. The `testForAngular` client side script
remains available however it's not recommended for use.

## waitForAngular

`waitForAngular` is protractor's second method for syncing with Angular.
`waitForAngular` is automatically invoked before selected webdriver commands
to eliminate the need for waits.

The following webdriver commands execute `waitForAngular` before running.
The single exception is `get`, in that case `waitForAngular` executes after
the `get` command completes.

Internal Command     | Driver command
                 --- | ---
`:getCurrentUrl`     | driver.current_url
`:get`               | driver.get 'http://www.angularjs.org'
`:refresh`           | driver.navigate.refresh
`:getPageSource`     | driver.page_source
`:getTitle`          | driver.title
`:findElement`       | driver.find_element(:tag_name, 'html')
`:findElements`      | driver.find_elements(:tag_name, 'html')
`:findChildElement`  | driver.find_element(:tag_name, 'html').find_element(:xpath, '//html') 
`:findChildElements` | driver.find_element(:tag_name, 'html').find_elements(:xpath, '//html')
 
The following custom Protractor commands also automatically execute `waitForAngular`
 
Protractor Command             | Note
                           --- | ---
`Protractor.get 'url'`         | driver.get redirects to protractor.get  
`Protractor.setLocation 'url'` | Note this is unrelated to the selenium setLocation for geographic position
`Protractor.getLocationAbsUrl` |
`Protractor.sync`              | Internal method used to sync webdriver commands. Not for end users.


Sync can be toggled by running:

- `protractor.ignore_sync = true` Don't run waitForAngular
- `protractor.ignore_sync = false` Run waitForAngular

To get always get a url without syncing use:

`protractor.driver_get 'url'`
