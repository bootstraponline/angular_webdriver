module AngularWebdriver
  # dynamically populated upon protractor init
  # provides by and element methods as top level singleton methods
  # in addition to being defined within the rspechelpers module
  module RSpecHelpers
  end

  # call within before(:all) in rspec config after invoking Protractor.new
  def self.install_rspec_helpers
    context = RSpec::Core::ExampleGroup
    helpers = AngularWebdriver::RSpecHelpers
    helpers.singleton_methods.each do |method_symbol|
      context.send(:define_method, method_symbol) do |*args|
        args.length == 0 ? helpers.send(method_symbol) :
                           helpers.send(method_symbol, *args)
      end
    end
  end
end
