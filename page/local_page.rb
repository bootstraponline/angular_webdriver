# http://localhost:8081/#/form
module Page
  class LocalPage
    include PageObject

    page_url 'http://localhost:8081/#/form'
    element(:greet_button) { element(by.binding('greet'))   }

    # alternatively just use the symbol name
    element(:greet_button2, binding: 'greet')
  end
end
