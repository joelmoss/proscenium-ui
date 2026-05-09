# frozen_string_literal: true

require 'application_system_test_case'

class DropdownMenuTest < ApplicationSystemTestCase
  describe 'opening and closing' do
    before { visit '/bare/dropdown_menu/basic' }

    it 'opens on trigger click' do
      find('pui-dropdown-trigger').click

      assert_selector 'pui-dropdown-menu[data-open]'
      assert_equal 'true', find('pui-dropdown-trigger')['aria-expanded']
    end

    it 'focuses the first menuitem on open' do
      find('pui-dropdown-trigger').click

      assert_selector 'pui-dropdown-menu[data-open]'
      focused = page.evaluate_script('document.activeElement && document.activeElement.textContent')
      assert_equal 'Profile', focused.to_s.strip
    end

    it 'closes when a menuitem is clicked' do
      find('pui-dropdown-trigger').click
      assert_selector 'pui-dropdown-menu[data-open]'

      find('a', text: 'Profile').click

      assert_no_selector 'pui-dropdown-menu[data-open]'
    end

    it 'does not close when a disabled item is clicked' do
      find('pui-dropdown-trigger').click
      assert_selector 'pui-dropdown-menu[data-open]'

      # JS dispatch — Playwright's actionability check treats aria-disabled
      # as non-clickable, but we want to verify our handler ignores the click
      # if a click does manage to reach the item.
      page.driver.with_playwright_page do |pw_page|
        pw_page.evaluate(<<~JS)
          () => document.querySelector('span[aria-disabled="true"]').click()
        JS
      end

      assert_selector 'pui-dropdown-menu[data-open]'
    end

    it 'closes on Esc and restores focus to trigger' do
      find('pui-dropdown-trigger').click
      assert_selector 'pui-dropdown-menu[data-open]'

      page.driver.with_playwright_page do |pw_page|
        pw_page.keyboard.press('Escape')
      end

      assert_no_selector 'pui-dropdown-menu[data-open]'
      focused_tag = page.evaluate_script(
        'document.activeElement && document.activeElement.tagName.toLowerCase()'
      )
      assert_equal 'pui-dropdown-trigger', focused_tag
    end
  end

  describe 'arrow-key navigation' do
    before do
      visit '/bare/dropdown_menu/basic'
      find('pui-dropdown-trigger').click
      assert_selector 'pui-dropdown-menu[data-open]'
    end

    it 'ArrowDown moves focus to the next item' do
      page.driver.with_playwright_page do |pw_page|
        pw_page.keyboard.press('ArrowDown')
      end

      focused = page.evaluate_script('document.activeElement.textContent')
      assert_equal 'Settings', focused.to_s.strip
    end

    it 'ArrowUp from the first item wraps to the last' do
      page.driver.with_playwright_page do |pw_page|
        pw_page.keyboard.press('ArrowUp')
      end

      focused = page.evaluate_script('document.activeElement.textContent')
      assert_equal 'Sign out', focused.to_s.strip
    end

    it 'End jumps to the last item' do
      page.driver.with_playwright_page do |pw_page|
        pw_page.keyboard.press('End')
      end

      focused = page.evaluate_script('document.activeElement.textContent')
      assert_equal 'Sign out', focused.to_s.strip
    end

    it 'Home jumps to the first item' do
      page.driver.with_playwright_page do |pw_page|
        pw_page.keyboard.press('End')
        pw_page.keyboard.press('Home')
      end

      focused = page.evaluate_script('document.activeElement.textContent')
      assert_equal 'Profile', focused.to_s.strip
    end

    it 'skips disabled items during arrow nav' do
      # The demo has Profile, Settings, Invite teammates, [disabled Billing], Sign out.
      # From Invite teammates, ArrowDown should jump past disabled to Sign out.
      page.driver.with_playwright_page do |pw_page|
        pw_page.keyboard.press('ArrowDown') # Settings
        pw_page.keyboard.press('ArrowDown') # Invite teammates
        pw_page.keyboard.press('ArrowDown') # Sign out (skipping disabled Billing)
      end

      focused = page.evaluate_script('document.activeElement.textContent')
      assert_equal 'Sign out', focused.to_s.strip
    end
  end

  describe 'typeahead' do
    before do
      visit '/bare/dropdown_menu/basic'
      find('pui-dropdown-trigger').click
      assert_selector 'pui-dropdown-menu[data-open]'
    end

    it 'jumps to the first item starting with the typed letter' do
      page.driver.with_playwright_page do |pw_page|
        pw_page.keyboard.press('s') # Settings comes before Sign out alphabetically
      end

      focused = page.evaluate_script('document.activeElement.textContent')
      assert_equal 'Settings', focused.to_s.strip
    end
  end

  describe 'Tab dismisses' do
    before { visit '/bare/dropdown_menu/basic' }

    it 'closes the menu when Tab is pressed' do
      find('pui-dropdown-trigger').click
      assert_selector 'pui-dropdown-menu[data-open]'

      page.driver.with_playwright_page do |pw_page|
        pw_page.keyboard.press('Tab')
      end

      assert_no_selector 'pui-dropdown-menu[data-open]'
    end
  end
end
