# frozen_string_literal: true

require 'test_helper'

describe Proscenium::UI::DropdownMenu do
  let(:concrete_class) do
    Class.new(Proscenium::UI::DropdownMenu) do
      def trigger_template
        'Account'
      end

      def menu_template
        item(href: '/profile') { 'Profile' }
        item { 'Sign out' }
        item(disabled: true) { 'Billing' }
        hr
        item(href: '/help') { 'Help' }
      end
    end
  end

  let(:html) { view_context.render(concrete_class.new) }
  let(:page) { Capybara.string(html) }

  it 'side loads CSS and JS' do
    html

    keys = Proscenium::Importer.imported.keys
    assert_includes keys, "#{COMPONENTS_PATH}/dropdown_menu/index.js"
    assert_includes keys, "#{COMPONENTS_PATH}/dropdown_menu/index.css"
  end

  it 'renders pui-dropdown-menu as the host element' do
    assert page.has_css?('pui-dropdown-menu')
    assert page.has_no_css?('pui-dropdown-menu pui-dropdown')
  end

  describe 'trigger' do
    let(:trigger) { page.find('pui-dropdown-menu pui-dropdown-trigger') }

    it 'advertises a menu popup via aria-haspopup' do
      assert_equal 'menu', trigger['aria-haspopup']
    end

    it 'links to the container via aria-controls' do
      container = page.find('pui-dropdown-container', visible: :all)
      assert_equal container['id'], trigger['aria-controls']
    end
  end

  describe 'container' do
    let(:container) { page.find('pui-dropdown-container', visible: :all) }

    it 'has role=menu' do
      assert_equal 'menu', container['role']
    end

    it 'is a popover with auto dismissal' do
      assert_equal 'auto', container['popover']
    end
  end

  describe 'item helper' do
    it 'renders an anchor when href is given' do
      anchor = page.find('a[href="/profile"]', visible: :all)
      assert_equal 'menuitem', anchor['role']
      assert_equal '-1', anchor['tabindex']
      assert_equal 'Profile', anchor.text
    end

    it 'renders a button when no href is given' do
      button = page.find('button[type="button"]', visible: :all, text: 'Sign out')
      assert_equal 'menuitem', button['role']
      assert_equal '-1', button['tabindex']
    end

    it 'renders a span with aria-disabled when disabled' do
      span = page.find('span[aria-disabled="true"]', visible: :all)
      assert_equal 'menuitem', span['role']
      assert_equal '-1', span['tabindex']
      assert_equal 'Billing', span.text
    end

    it 'forwards extra attributes to the underlying element' do
      cls = Class.new(Proscenium::UI::DropdownMenu) do
        def trigger_template
          'T'
        end

        def menu_template
          item(href: '/x', class: 'custom', data: { turbo: 'false' }) { 'Custom' }
        end
      end

      doc = Capybara.string(view_context.render(cls.new))
      anchor = doc.find('a[href="/x"]', visible: :all)
      assert_equal 'custom', anchor['class']
      assert_equal 'false', anchor['data-turbo']
    end
  end

  describe 'separator' do
    it 'renders an hr inside the body' do
      assert page.has_css?('pui-dropdown-body hr', visible: :all)
    end
  end

  describe 'abstract subclass requirements' do
    it 'raises NotImplementedError when menu_template is not implemented' do
      cls = Class.new(Proscenium::UI::DropdownMenu) do
        def trigger_template
          'Open'
        end
      end

      err = assert_raises(NotImplementedError) { view_context.render(cls.new) }
      assert_match(/menu_template/, err.message)
    end

    it 'raises NotImplementedError when trigger_template is not implemented' do
      cls = Class.new(Proscenium::UI::DropdownMenu) do
        def menu_template
          item { 'X' }
        end
      end

      err = assert_raises(NotImplementedError) { view_context.render(cls.new) }
      assert_match(/trigger_template/, err.message)
    end
  end
end
