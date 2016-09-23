# -- Trace
trace = false

if trace
  require 'trace_files'

  gem_dir                = File.join(`rvm gemdir`.strip, 'gems') # "/Users/user/.rvm/gems/ruby-2.2.2/gems"
  selenium_webdriver_gem = File.expand_path File.join(gem_dir, 'selenium-webdriver-2.53.4', 'lib', '**', '*.rb')
  watir_webdriver_gem    = File.expand_path File.join(gem_dir, 'watir-webdriver-0.7.0', 'lib', '**', '*.rb')

  targets = []
  targets += Dir.glob(File.join(__dir__, '../../lib/**/*.rb'))
  targets += Dir.glob(File.join(__dir__, '../../spec/**/*.rb'))
  targets += Dir.glob(selenium_webdriver_gem)
  targets += Dir.glob(watir_webdriver_gem)

  targets.map! { |t| File.expand_path t }
  puts "Tracing: #{targets}"

  TraceFiles.set trace: targets
end
