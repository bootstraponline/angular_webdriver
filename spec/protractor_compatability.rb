# see protractor_compatability_spec for example usage

class ProtractorElement
  attr_accessor :watir

  def initialize watir
    @watir = watir
  end

  def all args
    watir.elements *args
  end
end

def protractor_element
  @pelement ||= ProtractorElement.new @browser
end

def element args=nil
  return protractor_element unless args
  browser.element *args
end

class By
  class << self

    #
    # Selenium locators
    #

    def class what
      [:class, what]
    end

    def class_name what
      [:class_name, what]
    end

    def css what
      [:css, what]
    end

    def id what
      [:id, what]
    end

    def link what
      [:link, what]
    end

    def link_text what
      [:link_text, what]
    end

    def name what
      [:name, what]
    end

    def partial_link_text what
      [:partial_link_text, what]
    end

    def tag_name what
      [:tag_name, what]
    end

    def xpath what
      [:xpath, what]
    end

    #
    # Protractor locators
    #

    def binding what
      [:binding, what]
    end
  end
end

def by
  By
end

=begin
> Selenium::WebDriver::SearchContext::FINDERS
=> {:class=>"class name",
 :class_name=>"class name",
 :css=>"css selector",
 :id=>"id",
 :link=>"link text",
 :link_text=>"link text",
 :name=>"name",
 :partial_link_text=>"partial link text",
 :tag_name=>"tag name",
 :xpath=>"xpath",
 :binding=>"binding"}
=end
