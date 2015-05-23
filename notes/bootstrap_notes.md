# https://github.com/SeleniumHQ/selenium/blob/51fd82ec9cb1ebe7596bf7bb3fb8290113466a9a/rb/lib/selenium/webdriver/common/search_context.rb#L23
# protractor/lib/locators.js
#
# ProtractorBy.prototype.binding = function(bindingDescriptor) {
# return {
#   findElementsOverride: function(driver, using, rootSelector) {
#     return driver.findElements(
#         webdriver.By.js(clientSideScripts.findBindings,
#             bindingDescriptor, false, using, rootSelector));
#   },

```
=begin

executeAsyncScript_ & executeScript_ wrappers not required. The description
is visible only at the node.js level using a debugger,
it's not sent to the selenium server.

Server trace from executing browser.get('http://www.angularjs.org')

Protractor.prototype.get // protractor.js

clientSideScripts.testForAngular

pause angular bootstrap
Protractor.prototype.addBaseMockModules_
resume angular bootstrap

---

14:05:23.286 INFO - Executing: [get: data:text/html,<html></html>])
14:05:23.369 INFO - Done: [get: data:text/html,<html></html>]
14:05:23.391 INFO - Executing: [execute script: window.name = "NG_DEFER_BOOTSTRAP!" + window.name;window.location.replace("http://www.angularjs.org/");, []])
14:05:23.439 INFO - Done: [execute script: window.name = "NG_DEFER_BOOTSTRAP!" + window.name;window.location.replace("http://www.angularjs.org/");, []]
14:05:23.451 INFO - Executing: [execute script: return window.location.href;, []])
14:05:25.223 INFO - Done: [execute script: return window.location.href;, []]
14:05:25.234 INFO - Executing: [execute async script: try { return (function (attempts, asyncCallback) {
  var callback = function(args) {
    setTimeout(function() {
      asyncCallback(args);
    }, 0);
  };
  var check = function(n) {
    try {
      if (window.angular && window.angular.resumeBootstrap) {
        callback([true, null]);
      } else if (n < 1) {
        if (window.angular) {
          callback([false, 'angular never provided resumeBootstrap']);
        } else {
          callback([false, 'retries looking for angular exceeded']);
        }
      } else {
        window.setTimeout(function() {check(n - 1);}, 1000);
      }
    } catch (e) {
      callback([false, e]);
    }
  };
  check(attempts);
}).apply(this, arguments); }
catch(e) { throw (e instanceof Error) ? e : new Error(e); }, [10]])
14:05:25.298 INFO - Done: [execute async script: try { return (function (attempts, asyncCallback) {
  var callback = function(args) {
    setTimeout(function() {
      asyncCallback(args);
    }, 0);
  };
  var check = function(n) {
    try {
      if (window.angular && window.angular.resumeBootstrap) {
        callback([true, null]);
      } else if (n < 1) {
        if (window.angular) {
          callback([false, 'angular never provided resumeBootstrap']);
        } else {
          callback([false, 'retries looking for angular exceeded']);
        }
      } else {
        window.setTimeout(function() {check(n - 1);}, 1000);
      }
    } catch (e) {
      callback([false, e]);
    }
  };
  check(attempts);
}).apply(this, arguments); }
catch(e) { throw (e instanceof Error) ? e : new Error(e); }, [10]]
14:05:25.308 INFO - Executing: [execute script: return (function () {
    angular.module('protractorBaseModule_', []).
        config(['$compileProvider', function($compileProvider) {
          if ($compileProvider.debugInfoEnabled) {
            $compileProvider.debugInfoEnabled(true);
          }
        }]);
  }).apply(null, arguments);, []])
14:05:25.367 INFO - Done: [execute script: return (function () {
    angular.module('protractorBaseModule_', []).
        config(['$compileProvider', function($compileProvider) {
          if ($compileProvider.debugInfoEnabled) {
            $compileProvider.debugInfoEnabled(true);
          }
        }]);
  }).apply(null, arguments);, []]
14:05:25.375 INFO - Executing: [execute script: angular.resumeBootstrap(arguments[0]);, [[protractorBaseModule_]]])
14:05:26.553 INFO - Done: [execute script: angular.resumeBootstrap(arguments[0]);, [[protractorBaseModule_]]]
=end


=begin

trace for list(by.binding(''))

* execute async script functions.waitForAngular with default rootSelector body
* execute script (not async) functions.findBindings

14:20:14.396 INFO - Executing: [execute script: , []])
14:20:14.396 INFO - Executing: [execute async script: try { return (function (rootSelector, callback) {
  var el = document.querySelector(rootSelector);

  try {
    if (!window.angular) {
      throw new Error('angular could not be found on the window');
    }
    if (angular.getTestability) {
      angular.getTestability(el).whenStable(callback);
    } else {
      if (!angular.element(el).injector()) {
        throw new Error('root element (' + rootSelector + ') has no injector.' +
           ' this may mean it is not inside ng-app.');
      }
      angular.element(el).injector().get('$browser').
          notifyWhenNoOutstandingRequests(callback);
    }
  } catch (err) {
    callback(err.message);
  }
}).apply(this, arguments); }
catch(e) { throw (e instanceof Error) ? e : new Error(e); }, [body]])
14:20:14.482 INFO - Done: [execute script: , []]
14:20:14.669 INFO - Done: [execute async script: try { return (function (rootSelector, callback) {
  var el = document.querySelector(rootSelector);

  try {
    if (!window.angular) {
      throw new Error('angular could not be found on the window');
    }
    if (angular.getTestability) {
      angular.getTestability(el).whenStable(callback);
    } else {
      if (!angular.element(el).injector()) {
        throw new Error('root element (' + rootSelector + ') has no injector.' +
           ' this may mean it is not inside ng-app.');
      }
      angular.element(el).injector().get('$browser').
          notifyWhenNoOutstandingRequests(callback);
    }
  } catch (err) {
    callback(err.message);
  }
}).apply(this, arguments); }
catch(e) { throw (e instanceof Error) ? e : new Error(e); }, [body]]
14:20:14.697 INFO - Executing: [execute script: try { return (function (binding, exactMatch, using, rootSelector) {
  var root = document.querySelector(rootSelector || 'body');
  using = using || document;
  if (angular.getTestability) {
    return angular.getTestability(root).
        findBindings(using, binding, exactMatch);
  }
  var bindings = using.getElementsByClassName('ng-binding');
  var matches = [];
  for (var i = 0; i < bindings.length; ++i) {
    var dataBinding = angular.element(bindings[i]).data('$binding');
    if (dataBinding) {
      var bindingName = dataBinding.exp || dataBinding[0].exp || dataBinding;
      if (exactMatch) {
        var matcher = new RegExp('({|\\s|^|\\|)' + binding + '(}|\\s|$|\\|)');
        if (matcher.test(bindingName)) {
          matches.push(bindings[i]);
        }
      } else {
        if (bindingName.indexOf(binding) != -1) {
          matches.push(bindings[i]);
        }
      }

    }
  }
  return matches; /* Return the whole array for webdriver.findElements. */
}).apply(this, arguments); }
catch(e) { throw (e instanceof Error) ? e : new Error(e); }, [, false, null, body]])
14:20:14.850 INFO - Done: [execute script: try { return (function (binding, exactMatch, using, rootSelector) {
  var root = document.querySelector(rootSelector || 'body');
  using = using || document;
  if (angular.getTestability) {
    return angular.getTestability(root).
        findBindings(using, binding, exactMatch);
  }
  var bindings = using.getElementsByClassName('ng-binding');
  var matches = [];
  for (var i = 0; i < bindings.length; ++i) {
    var dataBinding = angular.element(bindings[i]).data('$binding');
    if (dataBinding) {
      var bindingName = dataBinding.exp || dataBinding[0].exp || dataBinding;
      if (exactMatch) {
        var matcher = new RegExp('({|\\s|^|\\|)' + binding + '(}|\\s|$|\\|)');
        if (matcher.test(bindingName)) {
          matches.push(bindings[i]);
        }
      } else {
        if (bindingName.indexOf(binding) != -1) {
          matches.push(bindings[i]);
        }
      }

    }
  }
  return matches; /* Return the whole array for webdriver.findElements. */
}).apply(this, arguments); }
catch(e) { throw (e instanceof Error) ? e : new Error(e); }, [, false, null, body]]
14:20:14.972 INFO - Executing: [get text: 0 [org.openqa.selenium.remote.RemoteWebElement@540378f1 -> unknown locator]])
14:20:15.006 INFO - Done: [get text: 0 [org.openqa.selenium.remote.RemoteWebElement@540378f1 -> unknown locator]]
14:20:15.019 INFO - Executing: [get text: 0 [org.openqa.selenium.remote.RemoteWebElement@540378f1 -> unknown locator]])
14:20:15.078 INFO - Done: [get text: 0 [org.openqa.selenium.remote.RemoteWebElement@540378f1 -> unknown locator]]
14:20:15.086 INFO - Executing: [get text: 1 [org.openqa.selenium.remote.RemoteWebElement@dee620f8 -> unknown locator]])
...
=end
```