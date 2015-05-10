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

  s.add_runtime_dependency 'selenium-webdriver', '>= 2.45.0'

  s.add_development_dependency 'rspec', '>= 3.2.0'
  s.add_development_dependency 'appium_thor', '>= 0.0.7'

  s.files = `git ls-files`.split "\n"
end
