require_relative 'spec_helper'

describe 'watir_patch' do

  it 'exists?' do
    visit 'async'

    no_wait { expect_equal element(by.css('does not exist')).exists?, false }

    expect_equal element(by.binding('slowHttpStatus')).exists?, true
  end
end
