module AngularWebdriver
  class ByRepeaterInner
    attr_reader :exact, :repeat_descriptor, :row_index, :column_binding

    # Takes args and returns wrapped repeater if the first arg is a repeater
    #
    # @param args [Array] args to wrap
    def self.wrap_repeater args
      if args && args.first.is_a?(self)
        [repeater: args.first.process] # watir requires an array containing a hash
      else
        args
      end
    end

    # Generate either by.repeater or by.exactRepeater
    # @option opts [Boolean] :exact exact matching
    # @option opts [String] :repeat_descriptor repeat description
    def initialize opts={}
      exact = opts.fetch(:exact)
      raise "#{exact} is not a valid value" unless [true, false].include?(exact)
      repeat_descriptor = opts.fetch(:repeat_descriptor)
      raise "#{repeat_descriptor} is not a valid repeat_descriptor" unless repeat_descriptor.is_a?(String)

      @exact             = exact
      @repeat_descriptor = repeat_descriptor
      self
    end

    def row row_index
      raise "#{row_index} is not a valid row index" unless row_index.is_a?(Integer)
      @row_index = row_index
      self
    end

    def column column_binding
      raise "#{column_binding} is not a valid column binding" unless column_binding.is_a?(String)
      @column_binding = column_binding
      self
    end

    # Return JSON representation of the correct repeater method and args
    def process
      # findRepeaterElement - (repeater, exact, index, binding, using, rootSelector) - by.repeater('baz in days').row(0).column('b') - [baz in days, false,    0,    b, null, body]
      # findRepeaterRows    - (repeater, exact, index, using)                        - by.repeater('baz in days').row(0)             - [baz in days, false,    0, null, body]
      # findRepeaterColumn  - (repeater, exact, binding, using, rootSelector)        - by.repeater('baz in days').column('b')        - [baz in days, false,    b, null, body]
      # findAllRepeaterRows - (repeater, exact, using)                               - by.repeater('baz in days')                    - [baz in days, false, null, body]
      #
      #
      # using        - parent element
      # rootSelector - selector for finding angular js
      # exact        - true if by.exactRepeater false when by.repeater
      #
      #
      # repeater (repeat_descriptor), binding (column_binding), index (row_index)
      #
      # findRepeaterElement - (repeat_descriptor, row_index, column_binding)
      # findRepeaterRows    - (repeat_descriptor, row_index)
      # findRepeaterColumn  - (repeat_descriptor, column_binding)
      # findAllRepeaterRows - (repeat_descriptor)

      result = if repeat_descriptor && row_index && column_binding
                 {
                   script: :findRepeaterElement,
                   args:   {
                     repeat_descriptor: repeat_descriptor,
                     exact:             exact,
                     row_index:         row_index,
                     column_binding:    column_binding,

                   }
                 }
               elsif repeat_descriptor && row_index
                 {
                   script: :findRepeaterRows,
                   args:   {
                     repeat_descriptor: repeat_descriptor,
                     exact:             exact,
                     row_index:         row_index
                   }
                 }
               elsif repeat_descriptor && column_binding
                 {
                   script: :findRepeaterColumn,
                   args:   {
                     repeat_descriptor: repeat_descriptor,
                     exact:             exact,
                     column_binding:    column_binding
                   }
                 }
               elsif repeat_descriptor
                 {
                   script: :findAllRepeaterRows,
                   args:   {
                     repeat_descriptor: repeat_descriptor,
                     exact:             exact
                   }
                 }
               else
                 raise 'Invalid repeater'
               end

      result.to_json
    end # def process
  end # class ByRepeaterInner
end # module AngularWebdriver
