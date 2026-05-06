# frozen_string_literal: true

require 'application_system_test_case'

class DropdownTest < ApplicationSystemTestCase
  describe 'opening and closing' do
    before { visit '/bare/dropdown/basic' }

    it 'is closed initially' do
      assert_no_selector 'pui-dropdown[data-open]'
      assert_equal 'false', find('pui-dropdown-trigger')['aria-expanded']
    end

    it 'opens on trigger click' do
      find('pui-dropdown-trigger').click

      assert_selector 'pui-dropdown[data-open]'
      assert_equal 'true', find('pui-dropdown-trigger')['aria-expanded']
    end

    it 'reflects open state on the container' do
      find('pui-dropdown-trigger').click

      assert_selector 'pui-dropdown-container[data-open]', visible: :all
    end

    it 'closes on second trigger click' do
      trigger = find('pui-dropdown-trigger')
      trigger.click
      assert_selector 'pui-dropdown[data-open]'

      trigger.click

      assert_no_selector 'pui-dropdown[data-open]'
      assert_equal 'false', find('pui-dropdown-trigger')['aria-expanded']
    end

    it 'closes on Esc' do
      find('pui-dropdown-trigger').click
      assert_selector 'pui-dropdown[data-open]'

      page.driver.with_playwright_page do |pw_page|
        pw_page.keyboard.press('Escape')
      end

      assert_no_selector 'pui-dropdown[data-open]'
    end

    it 'closes on click outside (browser light-dismiss)' do
      find('pui-dropdown-trigger').click
      assert_selector 'pui-dropdown[data-open]'

      page.driver.with_playwright_page do |pw_page|
        pw_page.mouse.click(500, 500)
      end

      assert_no_selector 'pui-dropdown[data-open]'
    end
  end

  describe 'keyboard activation' do
    before { visit '/bare/dropdown/basic' }

    it 'opens on Enter when trigger is focused' do
      page.driver.with_playwright_page do |pw_page|
        pw_page.evaluate("() => document.querySelector('pui-dropdown-trigger').focus()")
        pw_page.keyboard.press('Enter')
      end

      assert_selector 'pui-dropdown[data-open]'
    end

    it 'opens on Space when trigger is focused' do
      page.driver.with_playwright_page do |pw_page|
        pw_page.evaluate("() => document.querySelector('pui-dropdown-trigger').focus()")
        pw_page.keyboard.press('Space')
      end

      assert_selector 'pui-dropdown[data-open]'
    end

    it 'restores focus to trigger after Esc dismissal' do
      find('pui-dropdown-trigger').click
      assert_selector 'pui-dropdown[data-open]'

      page.driver.with_playwright_page do |pw_page|
        pw_page.keyboard.press('Escape')
      end
      assert_no_selector 'pui-dropdown[data-open]'

      focused_tag = page.evaluate_script(
        'document.activeElement && document.activeElement.tagName.toLowerCase()'
      )
      assert_equal 'pui-dropdown-trigger', focused_tag
    end
  end

  describe 'positioning' do
    before { visit '/bare/dropdown/basic' }

    it 'opens below the trigger with bottom-start placement' do
      find('pui-dropdown-trigger').click
      assert_selector 'pui-dropdown[data-open]'

      placement = page.evaluate_script(<<~JS)
        (() => {
          const t = document.querySelector('pui-dropdown-trigger').getBoundingClientRect();
          const c = document.querySelector('pui-dropdown-container').getBoundingClientRect();
          return { gap: c.top - t.bottom, leftDelta: c.left - t.left };
        })()
      JS

      assert_in_delta 6, placement['gap'], 1
      assert_in_delta 0, placement['leftDelta'], 2
    end
  end
end
