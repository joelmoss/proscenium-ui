# frozen_string_literal: true

require 'test_helper'

describe Proscenium::UI::Combobox do
  describe 'with static options' do
    render_subject do
      [
        options: [['United States', 'us'], %w[Canada ca]],
        name: 'country',
        placeholder: 'Select country...'
      ]
    end

    it 'renders custom element' do
      assert page.has_css?('pui-combobox')
    end

    it 'renders hidden input with name' do
      assert page.has_css?('input[type="hidden"][name="country"]', visible: :all)
    end

    it 'renders combobox input with ARIA attributes' do
      el = page.find('input[role="combobox"]')
      assert_equal 'list', el[:'aria-autocomplete']
      assert_equal 'false', el[:'aria-expanded']
    end

    it 'renders placeholder' do
      assert_equal 'Select country...', page.find('input[role="combobox"]')[:placeholder]
    end

    it 'renders listbox with options' do
      assert page.has_css?('ul[role="listbox"] li[role="option"]', visible: :all, count: 2)
      assert page.has_css?('li[role="option"][data-value="us"]', visible: :all,
                                                                 text: 'United States')
      assert page.has_css?('li[role="option"][data-value="ca"]', visible: :all, text: 'Canada')
    end
  end

  describe 'with string options' do
    render_subject do
      [options: %w[Red Green Blue], name: 'color']
    end

    it 'uses string for both label and value' do
      assert page.has_css?('li[role="option"][data-value="Red"]', visible: :all, text: 'Red')
      assert page.has_css?('li[role="option"][data-value="Green"]', visible: :all, text: 'Green')
    end
  end

  describe 'with a value' do
    render_subject do
      [
        options: [['United States', 'us'], %w[Canada ca]],
        name: 'country',
        value: 'us'
      ]
    end

    it 'sets hidden input value' do
      assert page.has_css?('input[type="hidden"][name="country"][value="us"]', visible: :all)
    end

    it 'marks option as selected' do
      assert page.has_css?('li[role="option"][data-value="us"][aria-selected="true"]',
                           visible: :all)
    end
  end

  describe 'multi-select' do
    render_subject do
      [
        options: [%w[Ruby 1], %w[Python 2], %w[Go 3]],
        name: 'tags',
        multiple: true,
        value: ['1']
      ]
    end

    it 'sets data-multiple attribute' do
      assert page.has_css?('pui-combobox[data-multiple]')
    end

    it 'renders empty hidden input for form submission' do
      assert page.has_css?('input[type="hidden"][name="tags"][value=""]', visible: :all)
    end

    it 'renders hidden inputs for selected values' do
      assert page.has_css?('input[type="hidden"][name="tags[]"][value="1"]', visible: :all)
    end

    it 'renders tags container' do
      assert page.has_css?('[part="tags"]')
    end

    it 'renders tag for selected value' do
      assert page.has_css?('[part="tag"][data-value="1"]', text: /Ruby/)
    end

    it 'renders tag remove button' do
      assert page.has_css?('[part="tag"] button[part="tag-remove"]')
    end
  end

  describe 'clear button' do
    describe 'single-select without value' do
      render_subject do
        [options: %w[Red Green Blue], name: 'color']
      end

      it 'renders hidden clear button' do
        btn = page.find('button[part="clear"]', visible: :all)
        assert_equal 'button', btn[:type]
        assert_equal '-1', btn[:tabindex]
        assert_equal 'Clear selection', btn[:'aria-label']
        assert btn[:hidden]
      end
    end

    describe 'single-select with value' do
      render_subject do
        [options: %w[Red Green Blue], name: 'color', value: 'Red']
      end

      it 'renders visible clear button' do
        btn = page.find('button[part="clear"]')
        assert_nil btn[:hidden]
      end
    end

    describe 'multiple mode' do
      render_subject do
        [options: %w[Red Green Blue], name: 'color', multiple: true]
      end

      it 'does not render clear button' do
        assert page.has_no_css?('button[part="clear"]', visible: :all)
      end
    end
  end

  describe 'toggle button' do
    describe 'single-select' do
      render_subject do
        [options: %w[Red Green Blue], name: 'color']
      end

      it 'renders toggle button' do
        btn = page.find('button[part="toggle"]')
        assert_equal 'button', btn[:type]
        assert_equal '-1', btn[:tabindex]
        assert_equal 'Toggle options', btn[:'aria-label']
      end
    end

    describe 'multiple mode' do
      render_subject do
        [options: %w[Red Green Blue], name: 'color', multiple: true]
      end

      it 'does not render toggle button' do
        assert page.has_no_css?('button[part="toggle"]')
      end
    end

    describe 'disabled' do
      render_subject do
        [options: %w[Red Green], name: 'color', disabled: true]
      end

      it 'renders disabled toggle button' do
        assert page.has_css?('button[part="toggle"][disabled]')
      end
    end
  end

  describe 'async mode' do
    render_subject do
      [name: 'user_id', src: '/api/users', placeholder: 'Search users...']
    end

    it 'renders hidden toggle button' do
      assert page.has_css?('button[part="toggle"][hidden]', visible: :all)
    end

    it 'renders hidden clear button' do
      assert page.has_css?('button[part="clear"][hidden]', visible: :all)
    end

    it 'sets data-src attribute' do
      assert page.has_css?('pui-combobox[data-src="/api/users"]')
    end

    it 'renders empty listbox' do
      assert page.has_css?('ul[role="listbox"]', visible: :all)
      assert page.has_no_css?('li[role="option"]', visible: :all)
    end
  end

  describe 'async multi-select with selected_options' do
    render_subject do
      [
        name: 'tag_ids',
        src: '/api/tags',
        multiple: true,
        value: ['1'],
        selected_options: [label: 'Ruby', value: '1']
      ]
    end

    it 'renders pre-selected tags' do
      assert page.has_css?('[part="tag"][data-value="1"]', text: /Ruby/)
    end
  end

  describe 'disabled' do
    render_subject do
      [
        options: %w[Red Green],
        name: 'color',
        disabled: true
      ]
    end

    it 'sets disabled attribute on custom element' do
      assert page.has_css?('pui-combobox[disabled]')
    end

    it 'sets disabled on combobox input' do
      assert page.has_css?('input[role="combobox"][disabled]')
    end
  end

  describe 'min_chars and debounce' do
    render_subject do
      [name: 'q', src: '/search', min_chars: 3, debounce: 500]
    end

    it 'sets data-min-chars' do
      assert page.has_css?('pui-combobox[data-min-chars="3"]')
    end

    it 'sets data-debounce' do
      assert page.has_css?('pui-combobox[data-debounce="500"]')
    end
  end

  describe 'default debounce is not rendered' do
    render_subject do
      [name: 'q', options: %w[A B]]
    end

    it 'does not set data-debounce when default' do
      assert page.has_no_css?('pui-combobox[data-debounce]')
    end

    it 'does not set data-min-chars when zero' do
      assert page.has_no_css?('pui-combobox[data-min-chars]')
    end
  end
end
