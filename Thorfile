require 'rubygems'
require 'appium_thor'

Appium::Thor::Config.set do
  gem_name 'angular_webdriver'
  github_owner 'bootstraponline'
end

# Must use '::' otherwise Default will point to Thor::Sandbox::Default
# Debug by calling Thor::Base.subclass_files via Pry
#
# https://github.com/erikhuda/thor/issues/484
#
class ::Default < Thor
  desc 'spec', 'Run RSpec tests'
  def spec
    exec 'parallel_rspec spec'
  end

  desc 'gen', 'Generate client_side_scripts.rb'
  def gen
    commands = [
      'node ./gen/scripts_to_json.js',
      'ruby ./gen/json_to_rb.rb'
    ].join ';'
    exec commands

    # only the first exec will work so we can't use two of them.
  end

  desc 'compare', 'Compare protractor JS specs to ruby specs'
  def compare
    commands = [
      'rspec ./gen/compare_specs.rb'
    ].join ';'
    exec commands
  end

  desc 'testapp', 'Start protractor test app'
  def testapp
    commands = [
      'cd protractor',
      'npm install .',
      'cd testapp',
      'npm start .'
    ].join ';'
    exec commands
  end
end
