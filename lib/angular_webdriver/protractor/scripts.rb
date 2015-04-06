require 'rubygems'
require 'json'
require 'ostruct'

client_side_scripts = OpenStruct.new JSON.parse File.read 'clientSideScripts.json'

puts client_side_scripts.waitForAngular
