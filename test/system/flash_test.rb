# frozen_string_literal: true

require 'application_system_test_case'

class FlashTest < ApplicationSystemTestCase
  describe 'Initial Render Toasts (attribute path)' do
    it 'renders a visible success toast for a notice flash' do
      visit '/bare/flash/basic'

      assert_toast_visible type: 'success', title: 'This is a success notification.'
    end

    it 'renders both success and warning toasts on the types page' do
      visit '/bare/flash/types'

      assert_toast_visible type: 'success', title: 'Something went well!'
      assert_toast_visible type: 'warning', title: 'Something needs your attention.'
      assert_equal 2, all('[data-sourdough-toast]').count
    end
  end

  describe 'Meta Tag Mutation Observer (Turbo/HTMX path)' do
    before do
      visit '/bare/flash/basic'

      # Wait for sourdough to boot and the mutation observer to attach. The
      # initial toast being visible is sufficient evidence.
      assert_toast_visible type: 'success', title: 'This is a success notification.'
    end

    it 'creates a visible success toast when a notice meta tag is added' do
      inject_flashes_meta('notice' => 'From Turbo')

      assert_toast_visible type: 'success', title: 'From Turbo'
    end

    it 'creates a visible error toast when an alert meta tag is added' do
      inject_flashes_meta('alert' => 'Boom')

      assert_toast_visible type: 'error', title: 'Boom'
    end

    it 'creates a new visible toast when meta tag content attribute changes' do
      inject_flashes_meta('notice' => 'First')
      assert_toast_visible type: 'success', title: 'First'

      update_flashes_meta('notice' => 'Second')
      assert_toast_visible type: 'success', title: 'Second'
    end
  end

  private

    # Asserts the toast is rendered AND actually visible to a user — not just
    # present in the DOM.
    #
    # `wait_for(state: 'visible')` covers display/visibility/bounding-box.
    # The opacity poll covers sourdough's fade-in animation (Playwright's
    # default visibility check ignores opacity). Filtering by title text
    # disambiguates when multiple toasts of the same type are on screen.
    def assert_toast_visible(type:, title:)
      page.driver.with_playwright_page do |pw_page|
        locator = pw_page
                  .locator(%([data-sourdough-toast][data-type="#{type}"]))
                  .filter(hasText: title)
                  .first
        locator.wait_for(state: 'visible', timeout: Capybara.default_max_wait_time * 1000)

        opacity = wait_for_opacity(locator)
        assert_operator opacity, :>, 0,
                        "expected toast (type=#{type}, title=#{title.inspect}) " \
                        "opacity > 0, was #{opacity}"

        actual_title = locator.locator('[data-title]').text_content.strip
        assert_equal title, actual_title
      end
    end

    def wait_for_opacity(locator)
      deadline = Time.zone.now + Capybara.default_max_wait_time
      opacity = 0.0
      while Time.zone.now < deadline
        opacity = locator.evaluate('el => getComputedStyle(el).opacity').to_f
        return opacity if opacity.positive?

        sleep 0.05
      end
      opacity
    end

    def inject_flashes_meta(flashes)
      content = flashes.to_json
      page.driver.with_playwright_page do |pw_page|
        pw_page.evaluate(<<~JS)
          () => {
            const meta = document.createElement('meta');
            meta.setAttribute('name', 'rails:flashes');
            meta.setAttribute('content', #{content.to_json});
            document.head.appendChild(meta);
          }
        JS
      end
    end

    def update_flashes_meta(flashes)
      content = flashes.to_json
      page.driver.with_playwright_page do |pw_page|
        pw_page.evaluate(<<~JS)
          () => {
            const meta = document.querySelector("meta[name='rails:flashes']");
            meta.setAttribute('content', #{content.to_json});
          }
        JS
      end
    end
end
