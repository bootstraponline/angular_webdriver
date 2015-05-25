# -- Trace
trace = false

if trace
  require 'trace_files'

  targets = Dir.glob(File.join(__dir__, '../../lib/**/*.rb'))
  targets.map! { |t| File.expand_path t }
  puts "Tracing: #{targets}"

  TraceFiles.set trace: targets
end
