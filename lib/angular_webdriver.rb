require_relative 'angular_webdriver/version'

require 'rubygems'
require 'selenium-webdriver'
require_relative 'angular_webdriver/protractor/webdriver_patch'

require_relative 'angular_webdriver/protractor/watir_patch'
AngularWebdriver.patch_watir # (1/2) before
require 'watir-webdriver'
AngularWebdriver.patch_watir # (2/2) after

require_relative 'angular_webdriver/protractor/by'
require_relative 'angular_webdriver/protractor/by_repeater_inner'
require_relative 'angular_webdriver/protractor/client_side_scripts'
require_relative 'angular_webdriver/protractor/protractor'
require_relative 'angular_webdriver/protractor/protractor_element'
require_relative 'angular_webdriver/protractor/rspec_helpers'
