require_relative 'spec_helper'

describe 'rspec_helpers' do
  def toplevel_main
    @toplevel_main ||= eval('self', TOPLEVEL_BINDING)
  end

  it 'no_wait exists within rspec context' do
    toplevel_main.no_wait { true }

    no_wait do
      true
    end

    # no_wait raises an arg error when not passed a block
    expect_error(ArgumentError) { toplevel_main.no_wait }
    expect_error(ArgumentError) { no_wait }
  end

  it 'by exists within rspec' do
    expected = { css: 'ok' }

    expect_equal toplevel_main.by.css('ok'), expected
    expect_equal by.css('ok'), expected

    expect_error(ArgumentError) { toplevel_main.by.css }
    expect_error(ArgumentError) { by.css }
  end

  it 'element exists within rspec' do
    expected = AngularWebdriver::ProtractorElement

    expect_equal toplevel_main.element.class, expected
    expect_equal element.class, expected
  end
end
