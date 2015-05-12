# angular_webdriver [![Gem Version](https://badge.fury.io/rb/angular_webdriver.svg)](https://rubygems.org/gems/angular_webdriver) [![Build Status](https://travis-ci.org/bootstraponline/angular_webdriver.svg?branch=master)](https://travis-ci.org/bootstraponline/angular_webdriver)

Angular enhancements to the Ruby webdriver bindings based on [protractor](https://github.com/angular/protractor).

## Testing

Tests run against protractor's [testapp](https://github.com/angular/protractor/blob/19b4bf21525a683c8cc3ba21018c194cac9b6426/testapp/index.html).

- `git clone git@github.com:angular/protractor.git`
- `cd testapp; npm install`
- `npm start` Test app will start on `http://localhost:8081/`

## Protractor CLI

Notes about protractor / angular testing.

--

[Protractor's Element Explorer](https://github.com/angular/protractor/blob/master/docs/debugging.md)

- `webdriver-manager update` Install webdriver jar
- `protractor --elementExplorer` Start protractor repl
- `.exit` Exit REPL session

View server logs

- `java -jar selenium-server-standalone-2.45.0.jar` Startup selenium server
- `nvm use v0.10.30`
- `protractor --elementExplorer --seleniumAddress 127.0.0.1:4444 --browser firefox` Tell protractor to connect to it

Known Issues:

- [protractor element explorer requires node v0.10.30](https://github.com/angular/protractor/issues/1890)
- [node >0.10.30 is broken and 0.12 doesn't work at all](https://github.com/angular/protractor/issues/1970#issuecomment-89371944)

Use [nvm](https://github.com/creationix/nvm) to manage node versions

- `brew install nvm` now update `~/.bash_profile` as instructed
- `nvm install v0.10.30` Install proper version of node
