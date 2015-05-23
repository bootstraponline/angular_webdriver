require_relative 'spec_helper'

describe 'logs' do
  it 'processes correctly' do
    targets = ['ruby_sync_spec_waithttp_raw.txt', 'nodejs_sync_spec_waithttp_raw.txt']

    targets.each do |target|
      angular_log = File.read File.join __dir__, target

      output_filename = target.sub(File.extname(target), '') + '_processed.txt'
      output_file     = File.join __dir__, output_filename

      File.open output_file, 'w' do |file|
        file.write Logs.process angular_log
      end
    end
  end
end
