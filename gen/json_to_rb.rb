require 'rubygems'
require 'json'
scripts_file = File.join __dir__, 'clientSideScripts.json'
raise "json file doesn't exist" unless File.exist?(scripts_file)
parsed       = JSON.parse(File.read(scripts_file))

# todo: automatically generate rspec tests based on json parsing to verify:
# all expect methods exist in source.rb as in the json and the string values
# are identical
source       = <<'S'
module ClientSideScripts

S


def method_for_key key, prefix=''
  method_name = key.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
  method_body = "@@client_side_scripts[:#{key}]"
  <<-"S"
  def #{prefix}#{method_name}
    #{method_body}
  end

  S
end

source += <<'S'
  # class methods

  def self.client_side_scripts
    @@client_side_scripts
  end

S

# class methods
parsed.keys.each do |key|
  source += method_for_key key, 'self.'
end

source += <<'S'
  @@client_side_scripts = {
S

parsed.each do |key, value|
  # must escape \ so that it matches the json exactly
  source += %Q( #{key}: %q(#{value.gsub('\\', '\\\\\\')}).freeze, \n)
end

source += <<'S'

  }.freeze
end
S

target = File.join __dir__, '../lib/angular_webdriver/protractor/client_side_scripts.rb'
target = File.expand_path target
File.delete(target) if File.exist?(target)

File.open(target, 'w') do |file|
  file.write source
end

raise "#{target} doesn't exist" unless File.exist?(target)

dir = File.expand_path File.dirname __dir__ # angular_webdriver root
puts "Created #{target.gsub(dir, '.')}"
