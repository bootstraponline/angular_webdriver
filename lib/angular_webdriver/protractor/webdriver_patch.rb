# https://github.com/SeleniumHQ/selenium/blob/1221ea539d92a46f392b00abccb9f48886415d26/rb/lib/selenium/webdriver/remote/bridge.rb#L576

require 'rubygems'
require 'selenium-webdriver'
require 'selenium/webdriver/common/search_context'
require 'selenium/webdriver/remote'
require 'selenium/webdriver/remote/bridge'

module Selenium
  module WebDriver
    SearchContext::FINDERS[:binding] = 'binding'

    class Driver
      def protractor
        @bridge.protractor
      end

      def protractor= protractor_object
        @bridge.protractor = protractor_object
      end
    end

    module Remote
      class Bridge
        attr_accessor :protractor

        def is_protractor? how
          %w[binding].include? how
        end

        # todo: attach protractor instance to selenium instead of using class methods
        def protractor_find(many, how, what, parent = nil)
          result = nil
          case how
            when 'binding'
              binding_descriptor = what
              using              = parent ? parent : false
              root_selector      = protractor.root_element
              args               = [binding_descriptor, false, using, root_selector]
              find_bindings_js   = protractor.client_side_scripts.find_bindings
              result             = executeScript(find_bindings_js, *args)
          end

          if many
            return result
          else
            result = result.first
            return result if result
            fail ::Selenium::WebDriver::Error::NoSuchElementError
          end
        end

        def find_element_by(how, what, parent = nil)
          if is_protractor? how
            return protractor_find(false, how, what, parent)
          end

          if parent
            id = execute :findChildElement, { :id => parent }, { :using => how, :value => what }
          else
            id = execute :findElement, {}, { :using => how, :value => what }
          end

          Element.new self, element_id_from(id)
        end

        def find_elements_by(how, what, parent = nil)
          if is_protractor? how
            return protractor_find(true, how, what, parent)
          end

          if parent
            ids = execute :findChildElements, { :id => parent }, { :using => how, :value => what }
          else
            ids = execute :findElements, {}, { :using => how, :value => what }
          end

          ids.map { |id| Element.new self, element_id_from(id) }
        end


        #
        # executes a command on the remote server.
        #
        #
        # Returns the 'value' of the returned payload
        #

        def execute(*args)
          protractor.sync(args.first) unless protractor.ignore_sync

          raw_execute(*args)['value']
        end

      end # class Bridge
    end # module Remote
  end # module WebDriver
end # module Selenium
