# phantomjs

phantomjs provides [ghostdriver](https://github.com/detro/ghostdriver) which is
suppose to be faster than regular browsers because it's headless. phantomjs is
buggy and unable to reliably execute selenium tests (as of v2.0). Tests will
fail and segfault exclusively on phantomjs and work properly on regular web
browsers.

#### Usage

- [Download phantomjs](http://phantomjs.org/download.html)
- `./phantomjs --webdriver=4444`
- Use remote webdriver `Watir::Browser.new :remote, desired_capabilities: Selenium::WebDriver::Remote::Capabilities.firefox`

#### Known issues

- [Official mac build of v2 is broken on OS X 10.10](https://github.com/ariya/phantomjs/issues/12900)
  - [work around by running](https://github.com/ariya/phantomjs/issues/12900#issuecomment-74073057)
    `brew install upx; upx -d bin/phantomjs`
- [Official linux builds do not exist](https://github.com/ariya/phantomjs/issues/12948)

The upcoming [v2.1 release](https://github.com/ariya/phantomjs/issues/12970) may
resolve the build issues. This is also blocking [phantomas](https://github.com/macbre/phantomas/issues/488)
