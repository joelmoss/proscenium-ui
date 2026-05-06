# frozen_string_literal: true

require 'test_helper'

describe Proscenium::UI::Dropdown do
  let(:concrete_class) do
    Class.new(Proscenium::UI::Dropdown) do
      def trigger_template
        'Open'
      end

      def dropdown_template
        a(href: '#') { 'Click me!' }
      end
    end
  end

  let(:html) { view_context.render(concrete_class.new) }
  let(:page) { Capybara.string(html) }

  it 'side loads CSS and JS' do
    html

    keys = Proscenium::Importer.imported.keys
    assert_includes keys, "#{COMPONENTS_PATH}/dropdown/index.js"
    assert_includes keys, "#{COMPONENTS_PATH}/dropdown/index.css"
  end

  it 'renders the host element' do
    assert page.has_css?('pui-dropdown')
  end

  describe 'trigger' do
    let(:trigger) { page.find('pui-dropdown-trigger') }

    it 'has button role and is keyboard-focusable' do
      assert_equal 'button', trigger['role']
      assert_equal '0', trigger['tabindex']
    end

    it 'advertises a popup via aria-haspopup' do
      assert_equal 'true', trigger['aria-haspopup']
    end

    it 'starts closed (aria-expanded=false)' do
      assert_equal 'false', trigger['aria-expanded']
    end

    it 'wires click and keydown actions' do
      assert_equal 'toggle', trigger['on-click']
      assert_equal 'onTriggerKey', trigger['on-keydown']
    end

    it 'renders trigger_template content' do
      assert_equal 'Open', trigger.text
    end

    it 'links to container via aria-controls' do
      container = page.find('pui-dropdown-container', visible: :all)
      assert_equal container['id'], trigger['aria-controls']
    end
  end

  describe 'container' do
    let(:container) { page.find('pui-dropdown-container', visible: :all) }

    it 'is a popover with auto dismissal' do
      assert_equal 'auto', container['popover']
    end

    it 'has a unique id' do
      assert_match(/^pui-dd-/, container['id'])
    end

    it 'wraps the body' do
      assert container.has_css?('pui-dropdown-body', visible: :all)
    end

    it 'wraps the arrow' do
      assert container.has_css?('pui-dropdown-arrow', visible: :all)
    end

    it 'renders dropdown_template inside the body' do
      body = container.find('pui-dropdown-body', visible: :all)
      assert body.has_css?('a', text: 'Click me!', visible: :all)
    end
  end

  describe 'abstract subclass requirements' do
    it 'raises NotImplementedError when trigger_template is not implemented' do
      cls = Class.new(Proscenium::UI::Dropdown) do
        def dropdown_template
          'body'
        end
      end

      err = assert_raises(NotImplementedError) { view_context.render(cls.new) }
      assert_match(/trigger_template/, err.message)
    end

    it 'raises NotImplementedError when dropdown_template is not implemented' do
      cls = Class.new(Proscenium::UI::Dropdown) do
        def trigger_template
          'Open'
        end
      end

      err = assert_raises(NotImplementedError) { view_context.render(cls.new) }
      assert_match(/dropdown_template/, err.message)
    end
  end
end
