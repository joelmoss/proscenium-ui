# frozen_string_literal: true

require 'application_system_test_case'

class ComboboxTest < ApplicationSystemTestCase
  describe 'Static Filtering' do
    before { visit '/bare/combobox/basic' }

    it 'shows all options on focus when input is empty' do
      find('input[role="combobox"]').click
      listbox = find('ul[role="listbox"]')

      assert_not listbox[:hidden]
      assert_equal 7, listbox.all('li[role="option"]').count
    end

    it 'filters options by typed text (case-insensitive)' do
      input = find('input[role="combobox"]')
      input.click
      input.send_keys('re')

      options = all('li[role="option"]:not([hidden])')
      labels = options.map(&:text)

      assert_includes labels, 'Red'
      assert_includes labels, 'Green'
      assert_not_includes labels, 'Blue'
    end

    it 'hides listbox when no options match' do
      input = find('input[role="combobox"]')
      input.click
      input.send_keys('zzz')

      assert find('ul[role="listbox"]', visible: :all)[:hidden]
    end

    it 'restores all options when input is cleared' do
      input = find('input[role="combobox"]')
      input.click
      input.send_keys('re')

      assert_operator all('li[role="option"]').count, :<, 7

      # Clear the input using select-all + delete
      page.driver.with_playwright_page do |pw_page|
        pw_page.keyboard.press('Meta+a')
        pw_page.keyboard.press('Backspace')
      end
      input.click # re-trigger focus to show all options

      assert_equal 7, all('li[role="option"]:not([hidden])').count
    end
  end

  describe 'Single Select' do
    before { visit '/bare/combobox/basic' }

    it 'selects option by click' do
      input = find('input[role="combobox"]')
      input.click
      find('li[role="option"]', text: 'Blue').click

      assert_equal 'Blue', input.value
      assert_equal 'Blue', find('input[type="hidden"][name="color"]', visible: :all).value
      assert find('ul[role="listbox"]', visible: :all)[:hidden]
    end

    it 'replaces previous selection on new click' do
      input = find('input[role="combobox"]')
      input.click
      find('li[role="option"]', text: 'Blue').click

      assert_equal 'Blue', input.value

      input.send_keys(:down) # reopen listbox
      find('li[role="option"]', text: 'Red').click

      assert_equal 'Red', input.value
      assert_equal 'Red', find('input[type="hidden"][name="color"]', visible: :all).value
    end
  end

  describe 'Toggle Button' do
    before { visit '/bare/combobox/basic' }

    it 'clicking toggle button opens the listbox' do
      find('button[part="toggle"]').click

      assert_not find('ul[role="listbox"]')[:hidden]
    end

    it 'clicking toggle button again closes the listbox' do
      toggle = find('button[part="toggle"]')
      toggle.click

      assert_not find('ul[role="listbox"]')[:hidden]

      toggle.click

      assert find('ul[role="listbox"]', visible: :all)[:hidden]
    end
  end

  describe 'Keyboard Navigation' do
    before { visit '/bare/combobox/basic' }

    it 'ArrowDown opens listbox when closed' do
      input = find('input[role="combobox"]')
      input.send_keys(:down)

      assert_not find('ul[role="listbox"]')[:hidden]
    end

    it 'ArrowDown/ArrowUp navigate options' do
      input = find('input[role="combobox"]')
      input.click # focus + open listbox
      input.send_keys(:down) # first option (index 0)

      first_option = first('li[role="option"]')
      assert_not_nil first_option[:'data-active']
      assert_equal first_option[:id], input[:'aria-activedescendant']

      input.send_keys(:down) # second option (index 1)
      second_option = all('li[role="option"]')[1]
      assert_not_nil second_option[:'data-active']

      input.send_keys(:up) # back to first (index 0)
      first_option = first('li[role="option"]')
      assert_not_nil first_option[:'data-active']
    end

    it 'Home/End jump to first/last option' do
      input = find('input[role="combobox"]')
      input.click # open
      input.send_keys(:end)
      options = all('li[role="option"]')
      assert options.last[:'data-active'] || options.last['data-active'] == ''

      input.send_keys(:home)
      assert options.first[:'data-active'] || options.first['data-active'] == ''
    end

    it 'Enter selects active option' do
      input = find('input[role="combobox"]')
      input.send_keys(:down) # open + first option (focus opens, then arrow navigates)
      input.send_keys(:enter)

      assert_equal 'Red', input.value
      assert find('ul[role="listbox"]', visible: :all)[:hidden]
    end

    it 'Escape closes listbox' do
      input = find('input[role="combobox"]')
      input.send_keys(:down) # open

      assert_not find('ul[role="listbox"]')[:hidden]

      input.send_keys(:escape)

      assert find('ul[role="listbox"]', visible: :all)[:hidden]
    end
  end

  describe 'Multi-Select' do
    before { visit '/bare/combobox/multi_select' }

    it 'renders pre-selected tags on load' do
      tags = all('[part="tag"]')
      labels = tags.map { |t| t.text.strip.chomp("\u00D7").strip }

      assert_includes labels, 'Ruby'
      assert_includes labels, 'Rails'

      hidden_inputs = all('input[type="hidden"][name="tags[]"]', visible: :all)
      values = hidden_inputs.map(&:value)
      assert_includes values, 'Ruby'
      assert_includes values, 'Rails'
    end

    it 'clicking unselected option adds tag and hidden input' do
      input = find('input[role="combobox"]')
      input.click
      find('li[role="option"]', text: 'JavaScript').click

      assert_selector '[part="tag"]', text: /JavaScript/
      assert_selector 'input[type="hidden"][name="tags[]"][value="JavaScript"]',
                      visible: :all
    end

    it 'clicking selected option removes tag and hidden input' do
      input = find('input[role="combobox"]')
      input.click
      find('li[role="option"]', text: 'Ruby').click

      assert_no_selector '[part="tag"][data-value="Ruby"]'
      assert_no_selector 'input[type="hidden"][name="tags[]"][value="Ruby"]', visible: :all
    end

    it 'tag remove button removes that tag' do
      within('[part="tag"][data-value="Ruby"]') do
        find('[part="tag-remove"]').click
      end

      assert_no_selector '[part="tag"][data-value="Ruby"]'
      assert_no_selector 'input[type="hidden"][name="tags[]"][value="Ruby"]', visible: :all
    end

    it 'Backspace on empty input removes last tag' do
      input = find('input[role="combobox"]')
      input.send_keys(:backspace)

      tags = all('[part="tag"]')
      values = tags.pluck('data-value')

      assert_includes values, 'Ruby'
      assert_not_includes values, 'Rails'
    end

    it 'input clears after selection' do
      input = find('input[role="combobox"]')
      input.click
      input.send_keys('Java')
      find('li[role="option"]', text: 'JavaScript').click

      assert_equal '', input.value
    end
  end

  describe 'Async Search' do
    before { visit '/bare/combobox/async' }

    it 'does not fetch with fewer than min_chars' do
      combobox = first('pui-combobox')
      input = combobox.find('input[role="combobox"]')
      input.send_keys('A')

      # With min_chars: 2, a single char should not open the listbox
      sleep 0.5
      assert combobox.find('ul[role="listbox"]', visible: :all)[:hidden]
    end

    it 'fetches and displays results after min_chars' do
      combobox = first('pui-combobox')
      input = combobox.find('input[role="combobox"]')
      input.send_keys('Al')

      # Wait for debounce + fetch
      within(combobox) do
        assert_selector 'li[role="option"]', text: 'Alice'
        assert_selector 'li[role="option"]', text: 'Alicia'
        assert_no_selector 'li[role="option"]', text: 'Bob'
      end
    end

    it 'selects async result' do
      combobox = first('pui-combobox')
      input = combobox.find('input[role="combobox"]')
      input.send_keys('Al')

      within(combobox) do
        find('li[role="option"]', text: 'Alice').click
      end

      assert_equal 'Alice', input.value
      hidden = combobox.find('input[type="hidden"]', visible: :all)
      assert_equal '1', hidden.value
    end
  end

  describe 'Async Multi-Select' do
    before { visit '/bare/combobox/async' }

    it 'renders pre-selected tag from selected_options' do
      combobox = all('pui-combobox')[1]

      within(combobox) do
        assert_selector '[part="tag"]', text: /Alice/
        assert_selector 'input[type="hidden"][name="assignee_ids[]"][value="1"]', visible: :all
      end
    end

    it 'fetched options reflect existing selection' do
      combobox = all('pui-combobox')[1]
      input = combobox.find('input[role="combobox"]')
      input.send_keys('Al')

      within(combobox) do
        alice = find('li[role="option"]', text: 'Alice')
        assert_equal 'true', alice[:'aria-selected']

        alicia = find('li[role="option"]', text: 'Alicia')
        assert_nil alicia[:'aria-selected']
      end
    end
  end

  describe 'ARIA Attributes' do
    before { visit '/bare/combobox/basic' }

    it 'has correct initial ARIA state' do
      input = find('input[role="combobox"]')

      assert_equal 'combobox', input[:role]
      assert_equal 'false', input[:'aria-expanded']
      assert input[:'aria-controls']
      assert_equal 'list', input[:'aria-autocomplete']
    end

    it 'aria-expanded toggles on open/close' do
      input = find('input[role="combobox"]')

      assert_equal 'false', input[:'aria-expanded']

      input.send_keys(:down)
      assert_equal 'true', input[:'aria-expanded']

      input.send_keys(:escape)
      assert_equal 'false', input[:'aria-expanded']
    end

    it 'aria-activedescendant set during navigation, cleared on close' do
      input = find('input[role="combobox"]')
      input.click # open
      input.send_keys(:down) # first option

      assert_predicate input[:'aria-activedescendant'], :present?

      input.send_keys(:escape)

      assert_not input[:'aria-activedescendant'].present?
    end

    it 'aria-selected on selected option' do
      input = find('input[role="combobox"]')
      input.click
      find('li[role="option"]', text: 'Green').click

      # Reopen listbox with ArrowDown since input has text
      input.send_keys(:down)
      green = find('li[role="option"]', text: 'Green')
      assert_equal 'true', green[:'aria-selected']
    end
  end
end
