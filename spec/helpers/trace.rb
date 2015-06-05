# -- Trace
trace = true

if trace
  require 'trace_files'

  targets = []
  # targets += Dir.glob(File.join(__dir__, '../../lib/**/*.rb'))
  targets += Dir.glob(File.join(__dir__, '../../spec/**/*.rb'))
  targets.map! { |t| File.expand_path t }
  puts "Tracing: #{targets}"

  TraceFiles.set trace: targets
end
