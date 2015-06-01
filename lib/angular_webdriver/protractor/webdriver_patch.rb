# https://github.com/SeleniumHQ/selenium/blob/1221ea539d92a46f392b00abccb9f48886415d26/rb/lib/selenium/webdriver/remote/bridge.rb#L576

require 'rubygems'
require 'selenium-webdriver'
require 'selenium/webdriver/common/search_context'
require 'selenium/webdriver/remote'
require 'selenium/webdriver/remote/bridge'

module Selenium
  module WebDriver

    class Driver
      def protractor
        @bridge.protractor
      end

      def protractor= protractor_object
        @bridge.protractor = protractor_object
      end

      def bridge
        @bridge
      end

      #
      # Sets the wait time in seconds used when locating elements and
      # waiting for angular to load.
      #
      # @param value [Numeric] the amount of time to wait in seconds
      #
      # @return [Numeric] the wait time in seconds
      #
      def set_max_wait value
        @bridge.set_max_wait value
      end

      #
      # Returns the wait time in seconds used when locating elements and
      # waiting for angular to load.
      #
      def max_wait_seconds
        @bridge.max_wait_seconds
      end
    end

    module Remote
      class Bridge
        attr_accessor :protractor

        def set_max_wait value
          fail 'set_max_wait value must be a number' unless value.is_a?(Numeric)
          # ensure no negative values
          @max_wait_seconds = value >= 0 ? value : 0
        end

        def max_wait_seconds
          # default to 0
          @max_wait_seconds ||= 0
        end

        def protractor_find(many, how, what, parent = nil)
          timeout = max_wait_seconds

          # we have to waitForAngular here. unlike selenium locators,
          # protractor locators don't go through execute. execute uses
          # protractor.sync to run waitForAngular when finding elements.
          wait(timeout: timeout, bubble: true) { protractor.waitForAngular }

          using         = parent ? parent : false
          root_selector = protractor.root_element
          comment       = "Protractor find by.#{how}"

          # args order from locators.js
          case how
            when 'binding'
              binding_descriptor = what
              args               = [binding_descriptor, false, using, root_selector]
              protractor_js      = protractor.client_side_scripts.find_bindings
            when 'partialButtonText'
              search_text   = what
              args          = [search_text, using, root_selector]
              protractor_js = protractor.client_side_scripts.find_by_partial_button_text
            when 'buttonText'
              search_text   = what
              args          = [search_text, using, root_selector]
              protractor_js = protractor.client_side_scripts.find_by_button_text
            when 'model'
              model         = what
              args          = [model, using, root_selector]
              protractor_js = protractor.client_side_scripts.find_by_model
          end

          finder = lambda { protractor.executeScript_(protractor_js, comment, *args) }

          result = []

          # Ignore any exceptions here because find_elements returns
          # an empty array when there are no values found, not an error.
          ignore do
            wait_true(timeout) do
              result = finder.call
              result.length > 0
            end
          end

          result ||= []

          if many
            return result
          else
            result = result.first
            return result if result
            fail ::Selenium::WebDriver::Error::NoSuchElementError
          end
        end

        def find_element_by(how, what, parent = nil)
          if protractor.finder? how
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
          if protractor.finder? how
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
        # driver.get uses execute which invokes protractor.get
        # protractor.get needs to call driver.get without invoking
        # protractor.get.
        #
        # this is accomplished by using driver_get and raw_execute
        #

        def driver_get(url)
          raw_execute(:get, {}, :url => url)['value']
        end

        FIND_ELEMENT_METHODS  = [:findElement, :findChildElement].freeze
        FIND_ELEMENTS_METHODS = [:findElements, :findChildElements].freeze

        #
        # executes a command on the remote server.
        #
        #
        # Returns the 'value' of the returned payload
        #

        def execute(*args)
          raise 'Must initialize protractor' unless protractor
          method_symbol = args.first
          unless protractor.ignore_sync
            # override get method which has special sync logic
            # (not handled via sync method)
            if method_symbol == :get
              url = args.last[:url]
              return protractor.get url
            end

            protractor.sync method_symbol
          end

          timeout            = max_wait_seconds
          finder             = lambda { raw_execute(*args)['value'] }
          find_one_element   = FIND_ELEMENT_METHODS.include?(method_symbol)
          find_many_elements = FIND_ELEMENTS_METHODS.include?(method_symbol)

          if find_one_element
            wait(timeout: timeout, bubble: true) do
              finder.call
            end
          elsif find_many_elements
            result = []

            # Ignore any exceptions here because find_elements returns
            # an empty array when there are no values found, not an error.
            ignore do
              wait_true(timeout) do
                result = finder.call
                result.length > 0
              end
            end

            result ||= []
            result
          else # all other commands
            finder.call
          end
        end

      end # class Bridge
    end # module Remote
  end # module WebDriver
end # module Selenium
