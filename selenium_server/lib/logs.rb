class Logs
  # todo: write custom Java logger for selenium standalone
  # so that the logging data isn't such a mess.
  def self.process angular_log
    angular_log = angular_log.split(/\r?\n/)

    angular_log.each_index do |index|
      line           = angular_log[index]

      # raw:
      # 15:51:00.940 INFO [1] org.openqa.grid.selenium.GridLauncher - Launching a standalone server
      #
      # matched:
      # "15:51:00.940 INFO [1] org.openqa.grid.selenium.GridLauncher - "

      text_to_remove = line.match(/^\d{2}:\d{2}:\d{2}\.\d{3} [A-Z]+ \[\d+\] [^-]+ - /)

      if text_to_remove
        text_to_remove = text_to_remove.to_s
        line           = line.sub text_to_remove, ''

        angular_log[index] = line
      end
    end

    # now we have a giant blob of text
    angular_log = angular_log.compact.join("\n")

    match_script = lambda do |script, comment|
      angular_log.gsub!(script, comment)
    end

    scripts = ClientSideScripts

    # pattern match and gsub out the known client side scripts
    match_script.(scripts.test_for_angular, 'Protractor.testForAngular')
    match_script.(scripts.wait_for_angular, 'Protractor.waitForAngular')
    match_script.(scripts.find_bindings, 'Protractor by.binding')

    # .*? is a non-greedy match. will only match until the first 'Executing:'
    # without ? it'll greedily match through multiple 'Executing:'
    angular_log.gsub!(/(Done: .*?)\nExecuting:/m) do
      full   = Regexp.last_match[0] # full_match
      group1 = Regexp.last_match[1] # group match
      full.sub(group1, '').strip
    end

    angular_log
  end
end
