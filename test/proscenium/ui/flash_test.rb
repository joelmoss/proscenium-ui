# frozen_string_literal: true

require 'test_helper'

class Proscenium::UI::FlashTest < ActiveSupport::TestCase
  it 'side loads CSS' do
    view

    assert_equal ["#{COMPONENTS_PATH}/flash/index.js",
                  "#{COMPONENTS_PATH}/flash/index.css"],
                 Proscenium::Importer.imported.keys
  end

  it 'renders custom element' do
    assert view.has_element?('pui-flash')
  end

  it 'assigns data attribute' do
    controller.flash.now[:foo] = 'bar'
    assert_equal 'bar', view.find('pui-flash')['data-flash-foo']
  end
end
