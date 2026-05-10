# frozen_string_literal: true

require 'application_system_test_case'

class WebComponentTest < ApplicationSystemTestCase
  describe 'actions' do
    before { visit '/test/web_component/actions' }

    it 'invokes the action method on a matching click' do
      find_by_id('click-btn').click

      assert_log '#action-log', ['click:click-btn:click-btn']
    end

    it 'passes the closest [on-click] ancestor as the target argument' do
      page.driver.with_playwright_page do |pw_page|
        pw_page.evaluate("() => document.querySelector('#click-target-inner').click()")
      end

      assert_log '#action-log', ['click:click-target:click-target-inner']
    end

    it 'invokes the change action when an input value changes' do
      find_by_id('change-input').fill_in(with: 'hello')
      find_by_id('change-input').send_keys(:tab)

      assert_log '#action-log', ['change:change-input:hello']
    end

    it 'invokes the keydown action with the originating key' do
      find_by_id('key-input').send_keys('a')

      assert_log '#action-log', ['keydown:key-input:a']
    end
  end

  describe 'targets' do
    before { visit '/test/web_component/targets' }

    it 'exposes $xxxTarget and $xxxTargets via the prototype Proxy' do
      find_by_id('count-btn').click

      assert_log '#targets-log', ['menu:2:true:t1:sole']
    end

    it 'lets an explicit instance property override the proxy lookup' do
      find_by_id('override-btn').click

      assert_log '#targets-log', %w[override:overridden restore:t1]
    end

    it 'exposes $ and $$ helpers' do
      find_by_id('q-btn').click

      assert_log '#targets-log', ['q:sole:2:true']
    end
  end

  describe 'values' do
    before { visit '/test/web_component/values' }

    it 'reflects current text content via the reactive property' do
      find_by_id('read-btn').click

      assert_log '#values-log', ['read:0:world']
    end

    it 'updates the element text when the property is assigned' do
      find_by_id('inc-btn').click
      find_by_id('inc-btn').click
      find_by_id('read-btn').click

      assert_equal '2', find_by_id('count-display').text
      assert_log '#values-log', ['read:2:world']
    end
  end

  describe 'listen / dispatch / handleEvent' do
    before { visit '/test/web_component/events' }

    it 'resolves :event names to the component-namespaced form on listen' do
      find_by_id('self-btn').click

      assert_log '#events-log', ['self:pui-test-events:ping:fireSelf']
    end

    it 'routes namespaced event names to document' do
      find_by_id('doc-btn').click

      assert_log '#events-log', ['doc:other:event']
    end

    it 'routes ^prefix event names to document and strips the prefix' do
      find_by_id('caret-btn').click

      assert_log '#events-log', ['caret:plain-doc-event']
    end

    it 'falls back to handleEvent when no callback is given' do
      find_by_id('handle-btn').click

      assert_log '#events-log', ['onPing:1:handle']
    end

    it 'strips the component namespace before routing through handleEvent' do
      find_by_id('handle-btn').click
      find_by_id('handle-ns-btn').click

      assert_log '#events-log', ['onPing:1:handle', 'onPing:2:handleNs']
    end

    it 'accepts an options object as the second argument' do
      find_by_id('opts-btn').click

      # `once: true` should deliver the first event and silently drop the second.
      assert_log '#events-log', ['onPing:1:opts1']
    end

    it 'unlisten removes the listener' do
      find_by_id('unlisten-btn').click

      assert_log '#events-log', ['unsub:1']
    end

    it 'dispatch(:event) fires on the component, namespaces the type, and bubbles' do
      find_by_id('dispatch-self-btn').click

      assert_log '#events-log', ['d-self:pui-test-events:custom:1:true:pui-test-events']
    end

    it 'dispatch with already-namespaced componentName fires on the component' do
      find_by_id('dispatch-already-ns-btn').click

      assert_log '#events-log', ['d-already-ns:self']
    end

    it 'dispatch with a plain (non-namespaced) name fires on the document' do
      find_by_id('dispatch-plain-btn').click

      assert_log '#events-log', ['d-plain:doc']
    end
  end

  describe 'observed attributes and registration' do
    before { visit '/test/web_component/attributes' }

    it 'register() throws TypeError when componentName is missing' do
      entry = static_log_entry('no-name')

      assert_match(/TypeError:`componentName` must be defined/, entry)
    end

    it 'register() is idempotent when called twice for the same class' do
      assert_equal 'idempotent:ok', static_log_entry('idempotent')
    end

    it 'withMixins merges observedAttributes from each mixin' do
      assert_equal 'mixed-observes:true:true', static_log_entry('mixed-observes')
    end

    it 'register merges observedAttributes from the parent at registration time' do
      assert_equal 'merged-observes:true:true', static_log_entry('merged-observes')
    end

    it 'recognises dragstart, dragover, drop and dragend as action types' do
      assert_equal 'drag-actions:ok', static_log_entry('drag-actions')
    end

    it 'attributeChangedCallback routes to a camelCased <attr>Changed method' do
      page.driver.with_playwright_page do |pw_page|
        pw_page.evaluate(<<~JS)
          () => document.querySelector('#attrs-host').setAttribute('data-open', 'yes')
        JS
      end

      log = page.driver.with_playwright_page do |pw_page|
        pw_page.evaluate("() => document.querySelector('#attrs-host').attrLog")
      end

      # Initial connection sets data-open to 'no' (null → 'no'); then we changed it to 'yes'.
      assert_includes log, 'data-open:null->no'
      assert_includes log, 'data-open:no->yes'
    end

    it 'mixin-contributed attributes also fire their camelCased callbacks' do
      page.driver.with_playwright_page do |pw_page|
        pw_page.evaluate(<<~JS)
          () => {
            const el = document.querySelector('#mixed-host')
            el.setAttribute('data-foo', 'a2')
            el.setAttribute('data-bar', 'b2')
          }
        JS
      end

      log = page.driver.with_playwright_page do |pw_page|
        pw_page.evaluate("() => document.querySelector('#mixed-host').attrLog")
      end

      assert_includes log, 'data-foo:a->a2'
      assert_includes log, 'data-bar:b->b2'
    end
  end

  private

    # Wait for the log list to contain exactly the expected entries, then assert.
    def assert_log(selector, expected)
      page.driver.with_playwright_page do |pw_page|
        pw_page.wait_for_function(<<~JS, arg: { selector: selector, count: expected.size })
          ({ selector, count }) => document.querySelectorAll(`${selector} > li`).length >= count
        JS
      end

      actual = all("#{selector} > li").map(&:text)
      assert_equal expected, actual.first(expected.size)
    end

    # Read the static-log entry for a given label.
    def static_log_entry(label)
      page.driver.with_playwright_page do |pw_page|
        pw_page.wait_for_selector(%(#static-log > li[data-label="#{label}"]))
      end

      find(%(#static-log > li[data-label="#{label}"])).text
    end
end
