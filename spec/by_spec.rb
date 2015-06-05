require_relative 'spec_helper'

describe 'by' do

  def by_methods
    # note yaml_tag is added automatically by ruby core psych
    @methods ||= (by.singleton_methods - [:yaml_tag]).sort
  end

  it 'defines camel case and snake case locators' do
    # \A\Z instead of ^$
    # http://sakurity.com/blog/2015/06/04/mongo_ruby_regexp.html

    methods       = by_methods
    actual_simple = methods.select { |m| m.match /\A[a-z]+\Z/ }.sort
    actual_snake  = methods.select { |m| m.to_s.include?('_') }.sort
    actual_camel  = methods.select { |m| m.match /[a-z][A-Z]/ }.sort
    actual_size   = methods.length

    simple = %i(
           binding
           class
           css
           id
           link
           model
           name
           options
           repeater
           xpath
    )

    snake = %i(
           button_text
           class_name
           css_containing_text
           deep_css
           exact_binding
           exact_repeater
           link_text
           partial_button_text
           partial_link_text
           tag_name
    )

    camel = %i(
           buttonText
           className
           cssContainingText
           deepCss
           exactBinding
           exactRepeater
           linkText
           partialButtonText
           partialLinkText
           tagName
    )

    size = simple.length + snake.length + camel.length

    expect_equal actual_simple, simple
    expect_equal actual_snake, snake
    expect_equal actual_camel, camel
    expect_equal actual_size, size
  end

  it 'locates elements using camel and snake case' do
    visit 'form'

    # webdriver snake -> camel
    expect_equal element(by.tag_name('html')).present?, true
    expect_equal element(by.tagName('html')).present?, true

    # protractor camel -> snake
    camelArr = element.all(by.partialButtonText('text')).to_a
    expect(camelArr.length).to eq(4)
    expect(camelArr[0].id).to eq('exacttext')

    snakeArr = element.all(by.partial_button_text('text')).to_a
    expect(snakeArr.length).to eq(4)
    expect(snakeArr[0].id).to eq('exacttext')
  end

  it 'all by methods return the expected class' do
    by_methods.each do |method_symbol|
      method   = by.method method_symbol
      # method arity is -1 for var args methods which doesn't help us.
      two_args = !!method_symbol.match(/\AcssContainingText|css_containing_text/)
      args     = two_args ? ['test', 'test'] : ['test']

      repeater       = method_symbol.to_s.downcase.include?('repeater')
      expected_class = repeater ? AngularWebdriver::ByRepeaterInner : Hash

      result = method.call(*args)
      expect_equal result.class, expected_class
    end
  end

  it 'defines by and elements on top level' do
    main = eval('self', TOPLEVEL_BINDING)

    # by.class is a locator so don't use .class. by invoked alone will
    # return the class.
    expect_equal main.by, AngularWebdriver::By
    expect_equal main.element.class, AngularWebdriver::ProtractorElement
  end

  it 'does not pollute object with extra methods' do
    method_whitelist = %i[
      yaml_tag
      allocate
      new
      superclass
      json_creatable?
      any_instance
      freeze
      ===
      ==
      <=>
      <
      <=
      >
      >=
      to_s
      inspect
      included_modules
      include?
      name
      ancestors
      instance_methods
      public_instance_methods
      protected_instance_methods
      private_instance_methods
      constants
      const_get
      const_set
      const_defined?
      const_missing
      class_variables
      remove_class_variable
      class_variable_get
      class_variable_set
      class_variable_defined?
      public_constant
      private_constant
      singleton_class?
      include
      prepend
      module_exec
      class_exec
      module_eval
      class_eval
      method_defined?
      public_method_defined?
      private_method_defined?
      protected_method_defined?
      public_class_method
      private_class_method
      autoload
      autoload?
      instance_method
      public_instance_method
      example_group
      describe
      context
      xdescribe
      xcontext
      fdescribe
      fcontext
      shared_examples
      shared_context
      shared_examples_for
      psych_yaml_as
      yaml_as
      pretty_print_cycle
      pretty_print
      psych_to_yaml
      to_yaml
      to_yaml_properties
      pry
      __binding__
      dclone
      to_json
      pretty_print_instance_variables
      pretty_print_inspect
      nil?
      =~
      !~
      eql?
      hash
      class
      singleton_class
      clone
      dup
      itself
      taint
      tainted?
      untaint
      untrust
      untrusted?
      trust
      frozen?
      methods
      singleton_methods
      protected_methods
      private_methods
      public_methods
      instance_variables
      instance_variable_get
      instance_variable_set
      instance_variable_defined?
      remove_instance_variable
      instance_of?
      kind_of?
      is_a?
      tap
      send
      public_send
      respond_to?
      extend
      display
      method
      public_method
      singleton_method
      define_singleton_method
      object_id
      to_enum
      enum_for
      gem
      pretty_inspect
      equal?
      !
      !=
      instance_eval
      instance_exec
      __send__
      __id__
      should_receive
      should_not_receive
      stub
      unstub
      stub_chain
      as_null_object
      null_object?
      received_message?
      should
      should_not
    ]

    difference = Object.methods - method_whitelist
    none       = []
    expect(difference).to eq(none)
  end
end
