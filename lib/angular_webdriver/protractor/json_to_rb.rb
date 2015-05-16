require 'rubygems'
require 'ostruct'
require 'json'
scripts_file = File.join __dir__, 'clientSideScripts.json'
parsed = OpenStruct.new(JSON.parse(File.read(scripts_file))).to_h

# todo: automatically generate rspec tests based on json parsing to verify:
# all expect methods exist in source.rb as in the json and the string values
# are identical
source = (<<'SRC').strip
class Protractor
  def self.client_side_scripts
    @@client_side_scripts
  end

  def client_side_scripts
    @@client_side_scripts
  end

  @@client_side_scripts = {
SRC

parsed.each do |key, value|
  source += %Q( #{key}: %q(#{value}).freeze, \n)
end

source += <<'S'

  }.freeze
end
S

target = File.join __dir__, 'client_side_scripts.rb'

File.open(target,'w') do |file|
  file.write source
end
