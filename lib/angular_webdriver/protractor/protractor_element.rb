# see protractor_compatability_spec for example usage
# designed for use with watir-webdriver

# todo: avoid global browser / @browser

module AngularWebdriver
  class ProtractorElement
    attr_accessor :watir

    def initialize watir
      @watir = watir
    end

    # @return Watir::HTMLElementCollection
    def all *args
      watir.elements *args
    end
  end
end

def protractor_element
  @pelement ||= AngularWebdriver::ProtractorElement.new @browser
end

# @return Watir::HTMLElement
def element *args
  return protractor_element unless args.length > 0
  browser.element *args
end
