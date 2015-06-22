require_relative 'spec_helper'

describe 'page object' do
  it 'finds by custom protractor locator' do
    local_page.goto
    element(by.binding('greet')).present? # protractor locator can be used directly
    local_page.greet_button? # or inside a page object via block
    local_page.greet_button2? # or inside a page object via symbol
  end
end
