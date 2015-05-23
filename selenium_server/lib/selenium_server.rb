require 'rubygems'
require 'posix/spawn'

require_relative 'logs'

logfile = 'log.txt'
File.delete logfile if File.exist? logfile

# the driver logs are different (driver.manage.logs.get(:driver)),
# better to spin up the jar and read logs from the output file
cmd     = "java -jar selenium-server-standalone-2.45.0.jar -log #{logfile}"

puts cmd

begin
  POSIX::Spawn::Child.new cmd
rescue Interrupt
  puts 'Server shutdown'
end

Logs.new(logfile).process
