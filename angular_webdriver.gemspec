require_relative 'lib/angular_webdriver/version'

Gem::Specification.new do |s|
  # 1.8.x is not supported
  s.required_ruby_version = '>= 1.9.3'

  s.name          = 'angular_webdriver'
  s.version       = AngularWebdriver::VERSION
  s.date          = AngularWebdriver::DATE
  s.license       = 'http://www.apache.org/licenses/LICENSE-2.0.txt'
  s.description   = s.summary = 'Angular webdriver'
  s.description   += '.' # avoid identical warning
  s.authors       = s.email = ['code@bootstraponline.com']
  s.homepage      = 'https://github.com/bootstraponline/angular_webdriver'
  s.require_paths = ['lib']

  # The selenium-webdriver and watir-webdriver patches may require updating
  # as the gems change. To ensure angular_webdriver continues to work
  # exact versions of both are used.
  s.add_runtime_dependency 'selenium-webdriver', '= 2.45.0'
  s.add_runtime_dependency 'watir-webdriver', '= 0.7.0'

  s.add_development_dependency 'rspec', '>= 3.2.0'
  s.add_development_dependency 'appium_thor', '>= 0.0.7'
  s.add_development_dependency 'pry', '>= 0.10.1'
  s.add_development_dependency 'webdriver_utils', '>= 0.0.4'
  s.add_development_dependency 'trace_files', '~> 0.0.2'

  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(gen|test|spec|features|protractor)/})
  end
end
