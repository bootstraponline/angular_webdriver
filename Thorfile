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
  no_commands do
    def run_commands commands
      # only the first exec will work so we can't use two of them.
      # bypass by joining the commands into one big command
      exec Array(commands).join ';'
    end
  end

  desc 'spec', 'Run RSpec tests'
  def spec
    run_commands 'parallel_rspec spec'
  end

  desc 'gen', 'Generate client_side_scripts.rb'
  def gen
    run_commands [
                   'node ./gen/scripts_to_json.js',
                   'ruby ./gen/json_to_rb.rb'
                 ]
  end

  desc 'compare', 'Compare protractor JS specs to ruby specs'
  def compare
    run_commands 'rspec ./gen/compare_specs.rb'
  end

  desc 'testapp', 'Start protractor test app'
  def testapp
    run_commands [
      'cd protractor',
      'npm install .',
      'cd testapp',
      'npm start .'
    ]
  end
end
