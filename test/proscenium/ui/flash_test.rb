# frozen_string_literal: true

require 'test_helper'

describe Proscenium::UI::Flash do
  render_subject

  it 'side loads CSS and JS' do
    render_subject

    assert_equal ["#{COMPONENTS_PATH}/flash/index.js",
                  "#{COMPONENTS_PATH}/flash/index.css"],
                 Proscenium::Importer.imported.keys
  end

  it 'renders custom element' do
    assert_element 'pui-flash'
  end

  it 'renders with no data attributes when flash is empty' do
    element = find('pui-flash')
    assert_nil element['data-flash-notice']
    assert_nil element['data-flash-alert']
  end

  context 'with notice flash' do
    it 'assigns data-flash-notice attribute' do
      controller.flash.now[:notice] = 'Success!'

      assert_equal 'Success!', find('pui-flash')['data-flash-notice']
    end
  end

  context 'with alert flash' do
    it 'assigns data-flash-alert attribute' do
      controller.flash.now[:alert] = 'Something went wrong.'

      assert_equal 'Something went wrong.', find('pui-flash')['data-flash-alert']
    end
  end

  context 'with multiple flash types' do
    it 'assigns all flash types as data attributes' do
      controller.flash.now[:notice] = 'Saved.'
      controller.flash.now[:alert] = 'Check your input.'

      element = find('pui-flash')
      assert_equal 'Saved.', element['data-flash-notice']
      assert_equal 'Check your input.', element['data-flash-alert']
    end
  end

  context 'with custom flash key' do
    it 'assigns custom key as data attribute' do
      controller.flash.now[:foo] = 'bar'

      assert_equal 'bar', find('pui-flash')['data-flash-foo']
    end
  end
end
