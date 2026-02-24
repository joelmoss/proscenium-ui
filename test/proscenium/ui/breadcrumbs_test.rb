# frozen_string_literal: true

require 'test_helper'

describe Proscenium::UI::Breadcrumbs do
  before do
    controller.class.include Proscenium::UI::Breadcrumbs::Control
  end

  render_subject

  context '@hide_breadcrumbs = true' do
    before do
      controller.instance_variable_set :@hide_breadcrumbs, true
    end

    it 'does not render' do
      assert_empty html
    end
  end

  context 'undefined @hide_breadcrumbs' do
    it 'side loads CSS' do
      render_subject
      assert_equal ["#{COMPONENTS_PATH}/breadcrumbs/index.css"],
                   Proscenium::Importer.imported.keys
    end

    it 'shows home element by default' do
      assert_equal '/', find('pui-breadcrumbs pui-breadcrumbs-home a')['href']
      assert_selector 'pui-breadcrumbs pui-breadcrumbs-home a>svg'
    end

    context "home_path: '/foo'" do
      render_subject home_path: '/foo'

      it 'uses custom home path' do
        assert_equal '/foo', find('pui-breadcrumbs pui-breadcrumbs-home a')['href']
      end
    end

    context 'with_home: false' do
      render_subject with_home: false

      it 'does not show home element' do
        assert_no_selector 'pui-breadcrumbs pui-breadcrumbs-home'
      end
    end

    context 'redefined #home_template' do
      let(:described_class) do
        Class.new(Proscenium::UI::Breadcrumbs) do
          def self.source_path = Proscenium::UI::Breadcrumbs.source_path

          private

            def home_template
              super { 'Hello' }
            end
        end
      end

      it 'renders #home_template' do
        assert_equal '/', find('pui-breadcrumbs pui-breadcrumbs-home a')['href']
        assert_equal 'Hello', find('pui-breadcrumbs pui-breadcrumbs-home a').text
      end
    end

    describe '#add_breadcrumb' do
      render_subject with_home: false

      context 'string name and path' do
        it 'renders breadcrumb as link' do
          controller.add_breadcrumb 'Foo', '/foo'

          assert find('pui-breadcrumbs pui-breadcrumbs-element a').has_content?('Foo')
          assert_equal '/foo', find('pui-breadcrumbs pui-breadcrumbs-element a')['href']
        end
      end

      context 'name only; as string' do
        it 'renders the name as-is, and does not render link' do
          controller.add_breadcrumb 'Foo'

          assert find('pui-breadcrumbs pui-breadcrumbs-element').has_content?('Foo')
          assert_no_selector 'pui-breadcrumbs pui-breadcrumbs-element a'
        end
      end

      context 'name as Symbol' do
        it 'calls controller method of the same name' do
          controller.class.define_method(:foo) { 'Foo' }
          controller.add_breadcrumb :foo

          assert find('pui-breadcrumbs pui-breadcrumbs-element').has_content?('Foo')
          assert_no_selector('pui-breadcrumbs pui-breadcrumbs-element a')
        end

        context 'name responds to :for_breadcrumb' do
          it 'calls method of the same name on the name object' do
            foo = Class.new do
              def for_breadcrumb = 'Foo'
            end
            controller.class.define_method(:foo) { foo.new }
            controller.add_breadcrumb :foo

            assert find('pui-breadcrumbs pui-breadcrumbs-element').has_content?('Foo')
            assert_no_selector('pui-breadcrumbs pui-breadcrumbs-element a')
          end
        end
      end

      context 'name responds to :for_breadcrumb' do
        it 'calls method of the same name on the name object' do
          foo = Class.new do
            def for_breadcrumb = 'Foo'
          end
          controller.add_breadcrumb foo.new

          assert find('pui-breadcrumbs pui-breadcrumbs-element').has_content?('Foo')
          assert_no_selector('pui-breadcrumbs pui-breadcrumbs-element a')
        end
      end

      context 'name as Symbol with leading @' do
        it 'calls controller instance variable of the same name' do
          controller.instance_variable_set :@foo, 'Foo'
          controller.add_breadcrumb :@foo

          assert find('pui-breadcrumbs pui-breadcrumbs-element').has_content?('Foo')
          assert_no_selector('pui-breadcrumbs pui-breadcrumbs-element a')
        end
      end

      context 'name as Proc' do
        it 'called with helpers as context' do
          controller.instance_variable_set :@foo, 'Foo'
          controller.add_breadcrumb -> { @foo }

          assert find('pui-breadcrumbs pui-breadcrumbs-element').has_content?('Foo')
          assert_no_selector('pui-breadcrumbs pui-breadcrumbs-element a')
        end
      end

      context 'name as Proc; path as Symbol' do
        it 'called with helpers as context' do
          controller.instance_variable_set :@foo, 'Foo'
          controller.add_breadcrumb -> { @foo }, :root

          assert find('pui-breadcrumbs pui-breadcrumbs-element').has_content?('Foo')
          assert_equal '/', find('pui-breadcrumbs pui-breadcrumbs-element a')['href']
        end
      end

      context 'path as Symbol' do
        it 'is passed to url_for' do
          controller.add_breadcrumb 'Foo', :root

          assert find('pui-breadcrumbs pui-breadcrumbs-element').has_content?('Foo')
          assert_equal '/', find('pui-breadcrumbs pui-breadcrumbs-element a')['href']
        end
      end

      context 'path as Symbol which is a controller method' do
        it 'calls controller method of the same name' do
          controller.class.define_method(:foo) { '/foo' }
          controller.add_breadcrumb 'Foo', :foo

          assert find('pui-breadcrumbs pui-breadcrumbs-element').has_content?('Foo')
          assert_equal '/foo', find('pui-breadcrumbs pui-breadcrumbs-element a')['href']
        end
      end

      context 'path as an Array' do
        it 'is passed to url_for' do
          controller.add_breadcrumb 'Foo', [:root]

          assert find('pui-breadcrumbs pui-breadcrumbs-element').has_content?('Foo')
          assert_equal '/', find('pui-breadcrumbs pui-breadcrumbs-element a')['href']
        end
      end

      context 'path as Proc' do
        it 'called with helpers as context' do
          controller.instance_variable_set :@foo, '/'
          controller.add_breadcrumb 'Foo', -> { @foo }

          assert find('pui-breadcrumbs pui-breadcrumbs-element').has_content?('Foo')
          assert_equal '/', find('pui-breadcrumbs pui-breadcrumbs-element a')['href']
        end
      end

      context 'path as Symbol with leading @' do
        it 'calls controller instance variable of the same name' do
          controller.instance_variable_set :@foo, '/foo'
          controller.add_breadcrumb 'Foo', :@foo

          assert find('pui-breadcrumbs pui-breadcrumbs-element').has_content?('Foo')
          assert_equal '/foo', find('pui-breadcrumbs pui-breadcrumbs-element a')['href']
        end
      end

      context 'path containing a Symbol with leading @' do
        it 'calls controller instance variable of the same name' do
          controller.instance_variable_set :@root_path, :root
          controller.add_breadcrumb 'Foo', :@root_path

          assert find('pui-breadcrumbs pui-breadcrumbs-element').has_content?('Foo')
          assert_equal '/', find('pui-breadcrumbs pui-breadcrumbs-element a')['href']
        end
      end
    end
  end
end
