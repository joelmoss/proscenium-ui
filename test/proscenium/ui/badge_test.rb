# frozen_string_literal: true

require 'test_helper'

describe Proscenium::UI::Badge do
  render_subject 'Active'

  it 'renders custom element' do
    assert page.has_css?('pui-badge')
  end

  it 'renders text content' do
    assert page.has_css?('pui-badge', text: 'Active')
  end

  it 'does not set data-variant when default' do
    assert page.has_no_css?('pui-badge[data-variant]')
  end

  it 'does not set data-size when md (default)' do
    assert page.has_no_css?('pui-badge[data-size]')
  end

  context 'variants' do
    it 'renders success variant' do
      render_subject 'OK', variant: :success
      assert page.has_css?('pui-badge[data-variant="success"]', text: 'OK')
    end

    it 'renders warning variant' do
      render_subject 'Caution', variant: :warning
      assert page.has_css?('pui-badge[data-variant="warning"]', text: 'Caution')
    end

    it 'renders danger variant' do
      render_subject 'Error', variant: :danger
      assert page.has_css?('pui-badge[data-variant="danger"]', text: 'Error')
    end

    it 'renders info variant' do
      render_subject 'Note', variant: :info
      assert page.has_css?('pui-badge[data-variant="info"]', text: 'Note')
    end
  end

  context 'size variants' do
    it 'renders sm size' do
      render_subject 'Small', size: :sm
      assert page.has_css?('pui-badge[data-size="sm"]', text: 'Small')
    end

    it 'renders lg size' do
      render_subject 'Large', size: :lg
      assert page.has_css?('pui-badge[data-size="lg"]', text: 'Large')
    end
  end

  context 'combined variants' do
    it 'renders with both variant and size' do
      render_subject 'Alert', variant: :danger, size: :lg
      assert page.has_css?('pui-badge[data-variant="danger"][data-size="lg"]', text: 'Alert')
    end
  end

  context 'rest attributes' do
    it 'passes additional attributes to pui_badge' do
      render_subject 'Active', id: 'status', class: 'my-class'
      assert page.has_css?('pui-badge#status.my-class', text: 'Active')
    end

    it 'deep merges data attributes' do
      render_subject 'Active', variant: :success, data: { foo: 'bar' }
      assert page.has_css?('pui-badge[data-variant="success"][data-foo="bar"]', text: 'Active')
    end
  end
end
