# angular_webdriver 

[![Gem Version](https://badge.fury.io/rb/angular_webdriver.svg)](https://rubygems.org/gems/angular_webdriver) [![Build Status](https://travis-ci.org/bootstraponline/angular_webdriver.svg?branch=master)](https://travis-ci.org/bootstraponline/angular_webdriver/builds) [![Coverage Status](https://coveralls.io/repos/bootstraponline/angular_webdriver/badge.svg?nocache)](https://coveralls.io/r/bootstraponline/angular_webdriver) [![Dependency Status](https://gemnasium.com/bootstraponline/angular_webdriver.svg?nocache)](https://gemnasium.com/bootstraponline/angular_webdriver)


Angular enhancements to the Ruby webdriver bindings based on [protractor](https://github.com/angular/protractor).

## Docs

See the [docs](docs/) folder for the documentation.

## Testing

Tests run against protractor's [testapp](https://github.com/angular/protractor/blob/19b4bf21525a683c8cc3ba21018c194cac9b6426/testapp/index.html).

The **latest** versions of Chrome and Firefox are required. The tests will
not run on old versions.

- `cd protractor/testapp; npm install`
- `npm start` Test app will start on `http://localhost:8081/`

## Protractor CLI

Notes about protractor / angular testing.

--

[Protractor's Element Explorer](https://github.com/angular/protractor/blob/master/docs/debugging.md)

- `npm install -g protractor` Install protractor
- `webdriver-manager update` Install webdriver jar
- `protractor --elementExplorer` Start protractor repl
- `.exit` Exit REPL session

#### View server logs

Startup selenium server using the jar or webdriver manager.

- `java -jar selenium-server-standalone-2.45.0.jar`
- `webdriver-manager start` 

Start element explorer using the standalone server to see the logs (protractor v2.1.0 or newer).

> protractor --elementExplorer --browser firefox --seleniumAddress http://127.0.0.1:4444/wd/hub 

Alternatively, run from source:

> node ./protractor/bin/webdriver-manager update
>
> node ./protractor/bin/protractor --elementExplorer --browser firefox --seleniumAddress http://127.0.0.1:4444/wd/hub
>
> browser.get('https://angularjs.org/')


#### Run individual protractor test

 - `cd protractor/; node lib/cli.js spec/basicConf.js`
 
 Modify basicConf to target only the single spec.
 
```
specs: [
  'basic/synchronize_spec.js'
],
```

Modify environment.js to default to firefox.

```
'browserName':
    (process.env.TEST_BROWSER_NAME || 'firefox'),
```

Make sure the test app is running.

#### Installing node

Use [nvm](https://github.com/creationix/nvm) to manage node versions

- `brew install nvm` Update `~/.bash_profile` as instructed
- `nvm install stable` Install latest stable version of node
- `nvm alias default stable` Set stable as the default node for new terminals
