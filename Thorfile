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
    exec 'rspec spec'
  end

  # todo: generate clientSideScripts.json before we use the json for
  # generating the rb file
  desc 'gen', 'Generate client_side_scripts.rb'
  def gen
    exec 'ruby ./lib/angular_webdriver/protractor/json_to_rb.rb'
  end
end
