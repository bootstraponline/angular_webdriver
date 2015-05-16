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
