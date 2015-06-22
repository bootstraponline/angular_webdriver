module AngularWebdriver
  # dynamically populated upon protractor init
  # provides by and element methods as top level singleton methods
  # in addition to being defined within the rspechelpers module
  module RSpecHelpers
  end

  class << self
    # call after invoking Protractor.new. Installs by/element/no_wait
    def install_rspec_helpers context = RSpec::Core::ExampleGroup
      helpers = AngularWebdriver::RSpecHelpers
      helpers.singleton_methods(false).each do |method_symbol|
        context.send(:define_method, method_symbol) do |*args, &block|
          args.length == 0 ? helpers.send(method_symbol, &block) :
            helpers.send(method_symbol, *args, &block)
        end
      end
    end

    def require_all_pages glob_path=nil
      base_dir = Rake.application.original_dir if defined?(Rake)
      base_dir ||= @original_dir ||= Dir.pwd

      glob_path ||= File.join(base_dir, 'page', '**', '*.rb')
      Dir.glob(glob_path) { |file| require_relative file }
    end

    def define_page_methods opts={}
      method        = opts.fetch(:method, :define_singleton_method)
      page_module   = opts[:page_module] || raise('must set page_module')
      target_class  = opts[:target_class] || raise('must set target_class')
      driver_object = opts[:watir] || opts[:driver] || raise('must set driver')
      page_module.constants.each do |page_class|
        qualified_class = page_module.const_get(page_class)

        # enable use of by/element/no_wait within block passed to pageobject element
        # element(:greet_button) { element(by.binding('greet'))   }
        AngularWebdriver.install_rspec_helpers qualified_class

        # ButtonsPage => buttons_page
        # https://github.com/rails/rails/blob/daaa21bc7d20f2e4ff451637423a25ff2d5e75c7/activesupport/lib/active_support/inflector/methods.rb#L96
        page_name = page_class.to_s.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
        target_class.send(method, page_name) do
          instance_name = "@#{page_module}#{page_class}"
          instance      = instance_variable_get(instance_name)
          return instance if instance
          obj = qualified_class.new driver_object
          instance_variable_set instance_name, obj
        end
      end
    end
  end # class << self
end # module AngularWebdriver
