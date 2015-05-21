module ClientSideScripts

  # class methods

  def self.client_side_scripts
    @@client_side_scripts
  end

  def self.wait_for_angular
    @@client_side_scripts[:waitForAngular]
  end

  def self.find_bindings
    @@client_side_scripts[:findBindings]
  end

  def self.find_repeater_rows
    @@client_side_scripts[:findRepeaterRows]
  end

  def self.find_all_repeater_rows
    @@client_side_scripts[:findAllRepeaterRows]
  end

  def self.find_repeater_element
    @@client_side_scripts[:findRepeaterElement]
  end

  def self.find_repeater_column
    @@client_side_scripts[:findRepeaterColumn]
  end

  def self.find_by_model
    @@client_side_scripts[:findByModel]
  end

  def self.find_by_options
    @@client_side_scripts[:findByOptions]
  end

  def self.find_by_button_text
    @@client_side_scripts[:findByButtonText]
  end

  def self.find_by_partial_button_text
    @@client_side_scripts[:findByPartialButtonText]
  end

  def self.find_by_css_containing_text
    @@client_side_scripts[:findByCssContainingText]
  end

  def self.test_for_angular
    @@client_side_scripts[:testForAngular]
  end

  def self.evaluate
    @@client_side_scripts[:evaluate]
  end

  def self.allow_animations
    @@client_side_scripts[:allowAnimations]
  end

  def self.get_location_abs_url
    @@client_side_scripts[:getLocationAbsUrl]
  end

  def self.set_location
    @@client_side_scripts[:setLocation]
  end

  def self.install_in_browser
    @@client_side_scripts[:installInBrowser]
  end

  @@client_side_scripts = {
 waitForAngular: %q(try { return (function (rootSelector, callback) {
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
catch(e) { throw (e instanceof Error) ? e : new Error(e); }).freeze, 
 findBindings: %q(try { return (function (binding, exactMatch, using, rootSelector) {
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
        var matcher = new RegExp('({|\\\\s|^|\\\\|)' +
            /* See http://stackoverflow.com/q/3561711 */
            binding.replace(/[\\-\\[\\]\\/\\{\\}\\(\\)\\*\\+\\?\\.\\\\\\^\\$\\|]/g, '\\\\$&') +
            '(}|\\\\s|$|\\\\|)');
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
catch(e) { throw (e instanceof Error) ? e : new Error(e); }).freeze, 
 findRepeaterRows: %q(try { return (function (repeater, exact, index, using) {
  function repeaterMatch(ngRepeat, repeater, exact) {
    if (exact) {
      return ngRepeat.split(' track by ')[0].split(' as ')[0].split('|')[0].
          trim() == repeater;
    } else {
      return ngRepeat.indexOf(repeater) != -1;
    }
  }

  using = using || document;

  var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\\\:'];
  var rows = [];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeaterMatch(repeatElems[i].getAttribute(attr), repeater, exact)) {
        rows.push(repeatElems[i]);
      }
    }
  }
  /* multiRows is an array of arrays, where each inner array contains
     one row of elements. */
  var multiRows = [];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat-start';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeaterMatch(repeatElems[i].getAttribute(attr), repeater, exact)) {
        var elem = repeatElems[i];
        var row = [];
        while (elem.nodeType != 8 ||
            !repeaterMatch(elem.nodeValue, repeater, exact)) {
          if (elem.nodeType == 1) {
            row.push(elem);
          }
          elem = elem.nextSibling;
        }
        multiRows.push(row);
      }
    }
  }
  var row = rows[index] || [], multiRow = multiRows[index] || [];
  return [].concat(row, multiRow);
 }).apply(this, arguments); }
catch(e) { throw (e instanceof Error) ? e : new Error(e); }).freeze, 
 findAllRepeaterRows: %q(try { return (function (repeater, exact, using) {
  function repeaterMatch(ngRepeat, repeater, exact) {
    if (exact) {
      return ngRepeat.split(' track by ')[0].split(' as ')[0].split('|')[0].
          trim() == repeater;
    } else {
      return ngRepeat.indexOf(repeater) != -1;
    }
  }

  using = using || document;

  var rows = [];
  var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\\\:'];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeaterMatch(repeatElems[i].getAttribute(attr), repeater, exact)) {
        rows.push(repeatElems[i]);
      }
    }
  }
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat-start';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeaterMatch(repeatElems[i].getAttribute(attr), repeater, exact)) {
        var elem = repeatElems[i];
        while (elem.nodeType != 8 ||
            !repeaterMatch(elem.nodeValue, repeater, exact)) {
          if (elem.nodeType == 1) {
            rows.push(elem);
          }
          elem = elem.nextSibling;
        }
      }
    }
  }
  return rows;
 }).apply(this, arguments); }
catch(e) { throw (e instanceof Error) ? e : new Error(e); }).freeze, 
 findRepeaterElement: %q(try { return (function (repeater, exact, index, binding, using, rootSelector) {
  function repeaterMatch(ngRepeat, repeater, exact) {
    if (exact) {
      return ngRepeat.split(' track by ')[0].split(' as ')[0].split('|')[0].
          trim() == repeater;
    } else {
      return ngRepeat.indexOf(repeater) != -1;
    }
  }

  var matches = [];
  var root = document.querySelector(rootSelector || 'body');
  using = using || document;

  var rows = [];
  var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\\\:'];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeaterMatch(repeatElems[i].getAttribute(attr), repeater, exact)) {
        rows.push(repeatElems[i]);
      }
    }
  }
  /* multiRows is an array of arrays, where each inner array contains
     one row of elements. */
  var multiRows = [];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat-start';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeaterMatch(repeatElems[i].getAttribute(attr), repeater, exact)) {
        var elem = repeatElems[i];
        var row = [];
        while (elem.nodeType != 8 || (elem.nodeValue &&
            !repeaterMatch(elem.nodeValue, repeater, exact))) {
          if (elem.nodeType == 1) {
            row.push(elem);
          }
          elem = elem.nextSibling;
        }
        multiRows.push(row);
      }
    }
  }
  var row = rows[index];
  var multiRow = multiRows[index];
  var bindings = [];
  if (row) {
    if (angular.getTestability) {
      matches.push.apply(
          matches,
          angular.getTestability(root).findBindings(row, binding));
    } else {
      if (row.className.indexOf('ng-binding') != -1) {
        bindings.push(row);
      }
      var childBindings = row.getElementsByClassName('ng-binding');
      for (var i = 0; i < childBindings.length; ++i) {
        bindings.push(childBindings[i]);
      }
    }
  }
  if (multiRow) {
    for (var i = 0; i < multiRow.length; ++i) {
      var rowElem = multiRow[i];
      if (angular.getTestability) {
        matches.push.apply(
            matches,
            angular.getTestability(root).findBindings(rowElem, binding));
      } else {
        if (rowElem.className.indexOf('ng-binding') != -1) {
          bindings.push(rowElem);
        }
        var childBindings = rowElem.getElementsByClassName('ng-binding');
        for (var j = 0; j < childBindings.length; ++j) {
          bindings.push(childBindings[j]);
        }
      }
    }
  }
  for (var i = 0; i < bindings.length; ++i) {
    var dataBinding = angular.element(bindings[i]).data('$binding');
    if (dataBinding) {
      var bindingName = dataBinding.exp || dataBinding[0].exp || dataBinding;
      if (bindingName.indexOf(binding) != -1) {
        matches.push(bindings[i]);
      }
    }
  }
  return matches;
}).apply(this, arguments); }
catch(e) { throw (e instanceof Error) ? e : new Error(e); }).freeze, 
 findRepeaterColumn: %q(try { return (function (repeater, exact, binding, using, rootSelector) {
  function repeaterMatch(ngRepeat, repeater, exact) {
    if (exact) {
      return ngRepeat.split(' track by ')[0].split(' as ')[0].split('|')[0].
          trim() == repeater;
    } else {
      return ngRepeat.indexOf(repeater) != -1;
    }
  }

  var matches = [];
  var root = document.querySelector(rootSelector || 'body');
  using = using || document;

  var rows = [];
  var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\\\:'];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeaterMatch(repeatElems[i].getAttribute(attr), repeater, exact)) {
        rows.push(repeatElems[i]);
      }
    }
  }
  /* multiRows is an array of arrays, where each inner array contains
     one row of elements. */
  var multiRows = [];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat-start';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeaterMatch(repeatElems[i].getAttribute(attr), repeater, exact)) {
        var elem = repeatElems[i];
        var row = [];
        while (elem.nodeType != 8 || (elem.nodeValue &&
            !repeaterMatch(elem.nodeValue, repeater, exact))) {
          if (elem.nodeType == 1) {
            row.push(elem);
          }
          elem = elem.nextSibling;
        }
        multiRows.push(row);
      }
    }
  }
  var bindings = [];
  for (var i = 0; i < rows.length; ++i) {
    if (angular.getTestability) {
      matches.push.apply(
          matches,
          angular.getTestability(root).findBindings(rows[i], binding));
    } else {
      if (rows[i].className.indexOf('ng-binding') != -1) {
        bindings.push(rows[i]);
      }
      var childBindings = rows[i].getElementsByClassName('ng-binding');
      for (var k = 0; k < childBindings.length; ++k) {
        bindings.push(childBindings[k]);
      }
    }
  }
  for (var i = 0; i < multiRows.length; ++i) {
    for (var j = 0; j < multiRows[i].length; ++j) {
      if (angular.getTestability) {
        matches.push.apply(
            matches,
            angular.getTestability(root).findBindings(multiRows[i][j], binding));
      } else {
        var elem = multiRows[i][j];
        if (elem.className.indexOf('ng-binding') != -1) {
          bindings.push(elem);
        }
        var childBindings = elem.getElementsByClassName('ng-binding');
        for (var k = 0; k < childBindings.length; ++k) {
          bindings.push(childBindings[k]);
        }
      }
    }
  }
  for (var j = 0; j < bindings.length; ++j) {
    var dataBinding = angular.element(bindings[j]).data('$binding');
    if (dataBinding) {
      var bindingName = dataBinding.exp || dataBinding[0].exp || dataBinding;
      if (bindingName.indexOf(binding) != -1) {
        matches.push(bindings[j]);
      }
    }
  }
  return matches;
}).apply(this, arguments); }
catch(e) { throw (e instanceof Error) ? e : new Error(e); }).freeze, 
 findByModel: %q(try { return (function (model, using, rootSelector) {
  var root = document.querySelector(rootSelector || 'body');
  using = using || document;

  if (angular.getTestability) {
    return angular.getTestability(root).
        findModels(using, model, true);
  }
  var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\\\:'];
  for (var p = 0; p < prefixes.length; ++p) {
    var selector = '[' + prefixes[p] + 'model="' + model + '"]';
    var elements = using.querySelectorAll(selector);
    if (elements.length) {
      return elements;
    }
  }
}).apply(this, arguments); }
catch(e) { throw (e instanceof Error) ? e : new Error(e); }).freeze, 
 findByOptions: %q(try { return (function (optionsDescriptor, using) {
  using = using || document;

  var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\\\:'];
  for (var p = 0; p < prefixes.length; ++p) {
    var selector = '[' + prefixes[p] + 'options="' + optionsDescriptor + '"] option';
    var elements = using.querySelectorAll(selector);
    if (elements.length) {
      return elements;
    }
  }
}).apply(this, arguments); }
catch(e) { throw (e instanceof Error) ? e : new Error(e); }).freeze, 
 findByButtonText: %q(try { return (function (searchText, using) {
  using = using || document;

  var elements = using.querySelectorAll('button, input[type="button"], input[type="submit"]');
  var matches = [];
  for (var i = 0; i < elements.length; ++i) {
    var element = elements[i];
    var elementText;
    if (element.tagName.toLowerCase() == 'button') {
      elementText = element.textContent || element.innerText || '';
    } else {
      elementText = element.value;
    }
    if (elementText.trim() === searchText) {
      matches.push(element);
    }
  }

  return matches;
}).apply(this, arguments); }
catch(e) { throw (e instanceof Error) ? e : new Error(e); }).freeze, 
 findByPartialButtonText: %q(try { return (function (searchText, using) {
  using = using || document;

  var elements = using.querySelectorAll('button, input[type="button"], input[type="submit"]');
  var matches = [];
  for (var i = 0; i < elements.length; ++i) {
    var element = elements[i];
    var elementText;
    if (element.tagName.toLowerCase() == 'button') {
      elementText = element.textContent || element.innerText || '';
    } else {
      elementText = element.value;
    }
    if (elementText.indexOf(searchText) > -1) {
      matches.push(element);
    }
  }

  return matches;
}).apply(this, arguments); }
catch(e) { throw (e instanceof Error) ? e : new Error(e); }).freeze, 
 findByCssContainingText: %q(try { return (function (cssSelector, searchText, using) {
  using = using || document;

  var elements = using.querySelectorAll(cssSelector);
  var matches = [];
  for (var i = 0; i < elements.length; ++i) {
    var element = elements[i];
    var elementText = element.textContent || element.innerText || '';
    if (elementText.indexOf(searchText) > -1) {
      matches.push(element);
    }
  }
  return matches;
}).apply(this, arguments); }
catch(e) { throw (e instanceof Error) ? e : new Error(e); }).freeze, 
 testForAngular: %q(try { return (function (attempts, asyncCallback) {
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
catch(e) { throw (e instanceof Error) ? e : new Error(e); }).freeze, 
 evaluate: %q(try { return (function (element, expression) {
  return angular.element(element).scope().$eval(expression);
}).apply(this, arguments); }
catch(e) { throw (e instanceof Error) ? e : new Error(e); }).freeze, 
 allowAnimations: %q(try { return (function (element, value) {
  var ngElement = angular.element(element);
  if (ngElement.allowAnimations) {
    // AngularDart: $testability API.
    return ngElement.allowAnimations(value);
  } else {
    // AngularJS
    var enabledFn = ngElement.injector().get('$animate').enabled;
    return (value == null) ? enabledFn() : enabledFn(value);
  }
}).apply(this, arguments); }
catch(e) { throw (e instanceof Error) ? e : new Error(e); }).freeze, 
 getLocationAbsUrl: %q(try { return (function (selector) {
  var el = document.querySelector(selector);
  if (angular.getTestability) {
    return angular.getTestability(el).
        getLocation();
  }
  return angular.element(el).injector().get('$location').absUrl();
}).apply(this, arguments); }
catch(e) { throw (e instanceof Error) ? e : new Error(e); }).freeze, 
 setLocation: %q(try { return (function (selector, url) {
  var el = document.querySelector(selector);
  if (angular.getTestability) {
    return angular.getTestability(el).
        setLocation(url);
  }
  var $injector = angular.element(el).injector();
  var $location = $injector.get('$location');
  var $rootScope = $injector.get('$rootScope');

  if (url !== $location.url()) {
    $location.url(url);
    $rootScope.$digest();
  }
}).apply(this, arguments); }
catch(e) { throw (e instanceof Error) ? e : new Error(e); }).freeze, 
 installInBrowser: %q(window.clientSideScripts = {waitForAngular: function (rootSelector, callback) {
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
}, findBindings: function (binding, exactMatch, using, rootSelector) {
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
        var matcher = new RegExp('({|\\\\s|^|\\\\|)' +
            /* See http://stackoverflow.com/q/3561711 */
            binding.replace(/[\\-\\[\\]\\/\\{\\}\\(\\)\\*\\+\\?\\.\\\\\\^\\$\\|]/g, '\\\\$&') +
            '(}|\\\\s|$|\\\\|)');
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
}, findRepeaterRows: function (repeater, exact, index, using) {
  function repeaterMatch(ngRepeat, repeater, exact) {
    if (exact) {
      return ngRepeat.split(' track by ')[0].split(' as ')[0].split('|')[0].
          trim() == repeater;
    } else {
      return ngRepeat.indexOf(repeater) != -1;
    }
  }

  using = using || document;

  var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\\\:'];
  var rows = [];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeaterMatch(repeatElems[i].getAttribute(attr), repeater, exact)) {
        rows.push(repeatElems[i]);
      }
    }
  }
  /* multiRows is an array of arrays, where each inner array contains
     one row of elements. */
  var multiRows = [];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat-start';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeaterMatch(repeatElems[i].getAttribute(attr), repeater, exact)) {
        var elem = repeatElems[i];
        var row = [];
        while (elem.nodeType != 8 ||
            !repeaterMatch(elem.nodeValue, repeater, exact)) {
          if (elem.nodeType == 1) {
            row.push(elem);
          }
          elem = elem.nextSibling;
        }
        multiRows.push(row);
      }
    }
  }
  var row = rows[index] || [], multiRow = multiRows[index] || [];
  return [].concat(row, multiRow);
 }, findAllRepeaterRows: function (repeater, exact, using) {
  function repeaterMatch(ngRepeat, repeater, exact) {
    if (exact) {
      return ngRepeat.split(' track by ')[0].split(' as ')[0].split('|')[0].
          trim() == repeater;
    } else {
      return ngRepeat.indexOf(repeater) != -1;
    }
  }

  using = using || document;

  var rows = [];
  var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\\\:'];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeaterMatch(repeatElems[i].getAttribute(attr), repeater, exact)) {
        rows.push(repeatElems[i]);
      }
    }
  }
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat-start';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeaterMatch(repeatElems[i].getAttribute(attr), repeater, exact)) {
        var elem = repeatElems[i];
        while (elem.nodeType != 8 ||
            !repeaterMatch(elem.nodeValue, repeater, exact)) {
          if (elem.nodeType == 1) {
            rows.push(elem);
          }
          elem = elem.nextSibling;
        }
      }
    }
  }
  return rows;
 }, findRepeaterElement: function (repeater, exact, index, binding, using, rootSelector) {
  function repeaterMatch(ngRepeat, repeater, exact) {
    if (exact) {
      return ngRepeat.split(' track by ')[0].split(' as ')[0].split('|')[0].
          trim() == repeater;
    } else {
      return ngRepeat.indexOf(repeater) != -1;
    }
  }

  var matches = [];
  var root = document.querySelector(rootSelector || 'body');
  using = using || document;

  var rows = [];
  var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\\\:'];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeaterMatch(repeatElems[i].getAttribute(attr), repeater, exact)) {
        rows.push(repeatElems[i]);
      }
    }
  }
  /* multiRows is an array of arrays, where each inner array contains
     one row of elements. */
  var multiRows = [];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat-start';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeaterMatch(repeatElems[i].getAttribute(attr), repeater, exact)) {
        var elem = repeatElems[i];
        var row = [];
        while (elem.nodeType != 8 || (elem.nodeValue &&
            !repeaterMatch(elem.nodeValue, repeater, exact))) {
          if (elem.nodeType == 1) {
            row.push(elem);
          }
          elem = elem.nextSibling;
        }
        multiRows.push(row);
      }
    }
  }
  var row = rows[index];
  var multiRow = multiRows[index];
  var bindings = [];
  if (row) {
    if (angular.getTestability) {
      matches.push.apply(
          matches,
          angular.getTestability(root).findBindings(row, binding));
    } else {
      if (row.className.indexOf('ng-binding') != -1) {
        bindings.push(row);
      }
      var childBindings = row.getElementsByClassName('ng-binding');
      for (var i = 0; i < childBindings.length; ++i) {
        bindings.push(childBindings[i]);
      }
    }
  }
  if (multiRow) {
    for (var i = 0; i < multiRow.length; ++i) {
      var rowElem = multiRow[i];
      if (angular.getTestability) {
        matches.push.apply(
            matches,
            angular.getTestability(root).findBindings(rowElem, binding));
      } else {
        if (rowElem.className.indexOf('ng-binding') != -1) {
          bindings.push(rowElem);
        }
        var childBindings = rowElem.getElementsByClassName('ng-binding');
        for (var j = 0; j < childBindings.length; ++j) {
          bindings.push(childBindings[j]);
        }
      }
    }
  }
  for (var i = 0; i < bindings.length; ++i) {
    var dataBinding = angular.element(bindings[i]).data('$binding');
    if (dataBinding) {
      var bindingName = dataBinding.exp || dataBinding[0].exp || dataBinding;
      if (bindingName.indexOf(binding) != -1) {
        matches.push(bindings[i]);
      }
    }
  }
  return matches;
}, findRepeaterColumn: function (repeater, exact, binding, using, rootSelector) {
  function repeaterMatch(ngRepeat, repeater, exact) {
    if (exact) {
      return ngRepeat.split(' track by ')[0].split(' as ')[0].split('|')[0].
          trim() == repeater;
    } else {
      return ngRepeat.indexOf(repeater) != -1;
    }
  }

  var matches = [];
  var root = document.querySelector(rootSelector || 'body');
  using = using || document;

  var rows = [];
  var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\\\:'];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeaterMatch(repeatElems[i].getAttribute(attr), repeater, exact)) {
        rows.push(repeatElems[i]);
      }
    }
  }
  /* multiRows is an array of arrays, where each inner array contains
     one row of elements. */
  var multiRows = [];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat-start';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeaterMatch(repeatElems[i].getAttribute(attr), repeater, exact)) {
        var elem = repeatElems[i];
        var row = [];
        while (elem.nodeType != 8 || (elem.nodeValue &&
            !repeaterMatch(elem.nodeValue, repeater, exact))) {
          if (elem.nodeType == 1) {
            row.push(elem);
          }
          elem = elem.nextSibling;
        }
        multiRows.push(row);
      }
    }
  }
  var bindings = [];
  for (var i = 0; i < rows.length; ++i) {
    if (angular.getTestability) {
      matches.push.apply(
          matches,
          angular.getTestability(root).findBindings(rows[i], binding));
    } else {
      if (rows[i].className.indexOf('ng-binding') != -1) {
        bindings.push(rows[i]);
      }
      var childBindings = rows[i].getElementsByClassName('ng-binding');
      for (var k = 0; k < childBindings.length; ++k) {
        bindings.push(childBindings[k]);
      }
    }
  }
  for (var i = 0; i < multiRows.length; ++i) {
    for (var j = 0; j < multiRows[i].length; ++j) {
      if (angular.getTestability) {
        matches.push.apply(
            matches,
            angular.getTestability(root).findBindings(multiRows[i][j], binding));
      } else {
        var elem = multiRows[i][j];
        if (elem.className.indexOf('ng-binding') != -1) {
          bindings.push(elem);
        }
        var childBindings = elem.getElementsByClassName('ng-binding');
        for (var k = 0; k < childBindings.length; ++k) {
          bindings.push(childBindings[k]);
        }
      }
    }
  }
  for (var j = 0; j < bindings.length; ++j) {
    var dataBinding = angular.element(bindings[j]).data('$binding');
    if (dataBinding) {
      var bindingName = dataBinding.exp || dataBinding[0].exp || dataBinding;
      if (bindingName.indexOf(binding) != -1) {
        matches.push(bindings[j]);
      }
    }
  }
  return matches;
}, findByModel: function (model, using, rootSelector) {
  var root = document.querySelector(rootSelector || 'body');
  using = using || document;

  if (angular.getTestability) {
    return angular.getTestability(root).
        findModels(using, model, true);
  }
  var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\\\:'];
  for (var p = 0; p < prefixes.length; ++p) {
    var selector = '[' + prefixes[p] + 'model="' + model + '"]';
    var elements = using.querySelectorAll(selector);
    if (elements.length) {
      return elements;
    }
  }
}, findByOptions: function (optionsDescriptor, using) {
  using = using || document;

  var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\\\:'];
  for (var p = 0; p < prefixes.length; ++p) {
    var selector = '[' + prefixes[p] + 'options="' + optionsDescriptor + '"] option';
    var elements = using.querySelectorAll(selector);
    if (elements.length) {
      return elements;
    }
  }
}, findByButtonText: function (searchText, using) {
  using = using || document;

  var elements = using.querySelectorAll('button, input[type="button"], input[type="submit"]');
  var matches = [];
  for (var i = 0; i < elements.length; ++i) {
    var element = elements[i];
    var elementText;
    if (element.tagName.toLowerCase() == 'button') {
      elementText = element.textContent || element.innerText || '';
    } else {
      elementText = element.value;
    }
    if (elementText.trim() === searchText) {
      matches.push(element);
    }
  }

  return matches;
}, findByPartialButtonText: function (searchText, using) {
  using = using || document;

  var elements = using.querySelectorAll('button, input[type="button"], input[type="submit"]');
  var matches = [];
  for (var i = 0; i < elements.length; ++i) {
    var element = elements[i];
    var elementText;
    if (element.tagName.toLowerCase() == 'button') {
      elementText = element.textContent || element.innerText || '';
    } else {
      elementText = element.value;
    }
    if (elementText.indexOf(searchText) > -1) {
      matches.push(element);
    }
  }

  return matches;
}, findByCssContainingText: function (cssSelector, searchText, using) {
  using = using || document;

  var elements = using.querySelectorAll(cssSelector);
  var matches = [];
  for (var i = 0; i < elements.length; ++i) {
    var element = elements[i];
    var elementText = element.textContent || element.innerText || '';
    if (elementText.indexOf(searchText) > -1) {
      matches.push(element);
    }
  }
  return matches;
}, testForAngular: function (attempts, asyncCallback) {
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
}, evaluate: function (element, expression) {
  return angular.element(element).scope().$eval(expression);
}, allowAnimations: function (element, value) {
  var ngElement = angular.element(element);
  if (ngElement.allowAnimations) {
    // AngularDart: $testability API.
    return ngElement.allowAnimations(value);
  } else {
    // AngularJS
    var enabledFn = ngElement.injector().get('$animate').enabled;
    return (value == null) ? enabledFn() : enabledFn(value);
  }
}, getLocationAbsUrl: function (selector) {
  var el = document.querySelector(selector);
  if (angular.getTestability) {
    return angular.getTestability(el).
        getLocation();
  }
  return angular.element(el).injector().get('$location').absUrl();
}, setLocation: function (selector, url) {
  var el = document.querySelector(selector);
  if (angular.getTestability) {
    return angular.getTestability(el).
        setLocation(url);
  }
  var $injector = angular.element(el).injector();
  var $location = $injector.get('$location');
  var $rootScope = $injector.get('$rootScope');

  if (url !== $location.url()) {
    $location.url(url);
    $rootScope.$digest();
  }
}};).freeze, 

  }.freeze
end
