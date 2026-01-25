# frozen_string_literal: true

require 'test_helper'

describe Proscenium::UI::Flash do
  render_subject

  it 'side loads CSS' do
    render_subject

    assert_equal ["#{COMPONENTS_PATH}/flash/index.js",
                  "#{COMPONENTS_PATH}/flash/index.css"],
                 Proscenium::Importer.imported.keys
  end

  it 'renders custom element' do
    assert_element 'pui-flash'
  end

  it 'assigns data attribute' do
    controller.flash.now[:foo] = 'bar'

    assert_equal 'bar', find('pui-flash')['data-flash-foo']
  end
end
