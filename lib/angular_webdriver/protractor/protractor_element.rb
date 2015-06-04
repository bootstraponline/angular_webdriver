module AngularWebdriver
  class ProtractorElement
    attr_reader :watir

    def initialize watir
      is_watir = watir.is_a?(Watir::Browser)
      raise 'Must init with a Watir::Browser' unless is_watir

      @watir = watir
    end

    # Protractor element
    #
    # Example:
    # element(by.css('bar'))
    #
    # @return Watir::HTMLElement
    def element *args
      return self unless args.length > 0
      watir.element *args
    end

    # Protractor all method.
    #
    # Example:
    # element.all(by.css('bar'))
    #
    # @return Watir::HTMLElementCollection
    def all *args
      watir.elements *args
    end
  end
end
