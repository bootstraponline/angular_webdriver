sync on find element(s) calls
browser.get('https://angularjs.org/')
element(by.id('the-basics')).getText()


protractor.js

var methodsToSync = ['getCurrentUrl', 'getPageSource', 'getTitle']; -- all of these wait for angular

Protractor.prototype.findElement      -- waits for angular
Protractor.prototype.findElements     -- waits for angular

Protractor.prototype.isElementPresent -- does **not** trigger wait for angular

Protractor.prototype.get              -- custom protractor method, waits for angular
Protractor.prototype.refresh          -- custom protractor method, waits for angular
Protractor.prototype.navigate         -- does not trigger wait for angular

Protractor.prototype.setLocation       -- custom protractor method -- client side script that already checks for angular.
Protractor.prototype.getLocationAbsUrl -- custom protractor method -- client side script that already checks for angular.
Protractor.prototype.debugger          -- custom protractor method -- client side script. doesn't wait.


todo: port custom protractor methods
todo: auto sync / use protractor replacements when ignore sync is false


redefine core selenium methods to auto sync before execution
to use commands (for example get) on non-angular pages, people can disable synchronization.

# ---

Selenium::WebDriver::Remote::COMMANDS.keys
=> [:newSession,
 :getCapabilities,
 :status,
 :getCurrentUrl, -- must sync
 :get,           -- must sync
 :goForward,     -- does not sync
 :goBack,        -- does not sync
 :refresh,       -- must sync
 :quit,
 :close,
 :getPageSource, -- must sync
 :getTitle,      -- must sync
 :findElement,   -- must sync
 :findElements,  -- must sync
 :getActiveElement,  -- does not sync
 :getCurrentWindowHandle, -- does not sync
 :getWindowHandles,
 :setWindowSize,
 :setWindowPosition,
 :getWindowSize,   -- does not sync
 :getWindowPosition,  -- does not sync
 :maximizeWindow,
 :executeScript,   -- does not sync
 :executeAsyncScript,  -- does not sync
 :screenshot,
 :dismissAlert,
 :acceptAlert,
 :getAlertText, -- does not sync
 :setAlertValue,
 :switchToFrame,
 :switchToParentFrame,
 :switchToWindow,
 :getCookies,
 :addCookie,
 :deleteAllCookies,
 :deleteCookie,
 :implicitlyWait,
 :setScriptTimeout,
 :setTimeout,
 :describeElement,
 :findChildElement, -- sync
 :findChildElements, -- sync
 :clickElement, 
 :submitElement,
 :getElementValue,
 :sendKeysToElement,
 :uploadFile,
 :getElementTagName,
 :clearElement,
 :isElementSelected,
 :isElementEnabled,
 :getElementAttribute,
 :elementEquals,
 :isElementDisplayed, -- does not sync
 :getElementLocation,
 :getElementLocationOnceScrolledIntoView,
 :getElementSize,
 :dragElement,
 :getElementValueOfCssProperty,
 :getElementText, -- does not sync
 :getScreenOrientation,
 :setScreenOrientation,
 :click, -- does not sync
 :doubleClick,
 :mouseDown,
 :mouseUp,
 :mouseMoveTo,
 :sendModifierKeyToActiveElement,
 :sendKeysToActiveElement,
 :executeSql,
 :getLocation,
 :setLocation, -- must sync
 :getAppCache,
 :getAppCacheStatus,
 :clearAppCache,
 :isBrowserOnline,
 :setBrowserOnline,
 :getLocalStorageItem,
 :removeLocalStorageItem,
 :getLocalStorageKeys,
 :setLocalStorageItem,
 :clearLocalStorage,
 :getLocalStorageSize,
 :getSessionStorageItem,
 :removeSessionStorageItem,
 :getSessionStorageKeys,
 :setSessionStorageItem,
 :clearSessionStorage,
 :getSessionStorageSize,
 :imeGetAvailableEngines,
 :imeGetActiveEngine,
 :imeIsActivated,
 :imeDeactivate,
 :imeActivateEngine,
 :touchSingleTap,
 :touchDoubleTap,
 :touchLongPress,
 :touchDown,
 :touchUp,
 :touchMove,
 :touchScroll,
 :touchFlick,
 :getAvailableLogTypes,
 :getLog]