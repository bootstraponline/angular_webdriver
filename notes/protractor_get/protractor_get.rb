=begin

var DEFAULT_RESET_URL = 'data:text/html,<html></html>';
if (browserName === 'internet explorer' || browserName === 'safari') {
  self.resetUrl = 'about:blank';
}


this.executeScript_(
'window.location.replace("' + destination + '");',
msg('reset url'))

self.executeAsyncScript_(clientSideScripts.testForAngular,


Protractor.prototype.get = function(destination, opt_timeout) {
  var timeout = opt_timeout ? opt_timeout : this.getPageTimeout;
  var self = this;

  destination = this.baseUrl.indexOf('file://') === 0 ?
    this.baseUrl + destination : url.resolve(this.baseUrl, destination);
  var msg = function(str) {
    return 'Protractor.get(' + destination + ') - ' + str;
  };

  if (this.ignoreSynchronization) {
    return this.driver.get(destination);
  }

  var deferred = webdriver.promise.defer();

  this.driver.get(this.resetUrl).then(null, deferred.reject);
  this.executeScript_(
      'window.name = "' + DEFER_LABEL + '" + window.name;' +
      'window.location.replace("' + destination + '");',
      msg('reset url'))
      .then(null, deferred.reject);

  // We need to make sure the new url has loaded before
  // we try to execute any asynchronous scripts.
  this.driver.wait(function() {
    return self.executeScript_('return window.location.href;', msg('get url')).
        then(function(url) {
          return url !== self.resetUrl;
        }, function(err) {
          if (err.code == 13) {
            // Ignore the error, and continue trying. This is because IE
            // driver sometimes (~1%) will throw an unknown error from this
            // execution. See https://github.com/angular/protractor/issues/841
            // This shouldn't mask errors because it will fail with the timeout
            // anyway.
            return false;
          } else {
            throw err;
          }
        });
  }, timeout,
  'waiting for page to load for ' + timeout + 'ms')
  .then(null, deferred.reject);

  // Make sure the page is an Angular page.
  self.executeAsyncScript_(clientSideScripts.testForAngular,
      msg('test for angular'),
      Math.floor(timeout / 1000)).
      then(function(angularTestResult) {
        var hasAngular = angularTestResult[0];
        if (!hasAngular) {
          var message = angularTestResult[1];
          throw new Error('Angular could not be found on the page ' +
              destination + ' : ' + message);
        }
      }, function(err) {
        throw 'Error while running testForAngular: ' + err.message;
      })
      .then(null, deferred.reject);

  // At this point, Angular will pause for us until angular.resumeBootstrap
  // is called.
  var moduleNames = [];
  for (var i = 0; i < this.mockModules_.length; ++i) {
    var mockModule = this.mockModules_[i];
    var name = mockModule.name;
    moduleNames.push(name);
    var executeScriptArgs = [mockModule.script, msg('add mock module ' + name)].
        concat(mockModule.args);
    this.executeScript_.apply(this, executeScriptArgs).
        then(null, function(err) {
          throw 'Error while running module script ' + name +
              ': ' + err.message;
        })
        .then(null, deferred.reject);
  }

  this.executeScript_(
      'angular.resumeBootstrap(arguments[0]);',
      msg('resume bootstrap'),
      moduleNames)
      .then(deferred.fulfill, deferred.reject);

  return deferred;
};
=end