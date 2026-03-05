# frozen_string_literal: true

require 'test_helper'

describe Proscenium::UI::Form do
  describe 'combobox_field' do
    let(:user) { User.new }

    def render_form(model = user, **opts, &block)
      @html = view_context.render(Proscenium::UI::Form.new(model, **opts, &block))
      @subject = Capybara.string(@html)
    end

    delegate :view_context, to: :controller

    def controller
      @controller ||= ActionView::TestCase::TestController.new
    end

    describe 'with static options' do
      it 'renders within a form field' do
        render_form { |f| f.combobox_field :gender, options: %w[Male Female Other] }
        assert @subject.has_css?('pui-combobox-field')
      end

      it 'renders a label' do
        render_form { |f| f.combobox_field :gender, options: %w[Male Female Other] }
        assert @subject.has_css?('pui-combobox-field label')
      end

      it 'renders the combobox component' do
        render_form { |f| f.combobox_field :gender, options: %w[Male Female Other] }
        assert @subject.has_css?('pui-combobox-field pui-combobox')
      end

      it 'renders options' do
        render_form { |f| f.combobox_field :gender, options: %w[Male Female Other] }
        assert @subject.has_css?('li[role="option"]', visible: :all, count: 3)
      end

      it 'generates correct field name' do
        render_form { |f| f.combobox_field :gender, options: %w[Male Female Other] }
        assert @subject.has_css?('input[type="hidden"][name="user[gender]"]', visible: :all)
      end
    end

    describe 'with enum attribute' do
      it 'auto-detects enum options' do
        render_form { |f| f.combobox_field :gender }
        assert @subject.has_css?('li[role="option"]', visible: :all, minimum: 2)
      end
    end

    describe 'with belongs_to association' do
      before do
        User.create! [{ name: 'Joel Moss' }, { name: 'Eve Moss' }]
      end

      let(:event) { Event.new }

      it 'auto-detects association options' do
        render_form(event) { |f| f.combobox_field :user }
        assert @subject.has_css?('li[role="option"]', visible: :all, count: 2)
      end
    end

    describe 'with async src' do
      it 'sets data-src on the combobox' do
        render_form { |f| f.combobox_field :gender, src: '/api/options', placeholder: 'Search...' }
        assert @subject.has_css?('pui-combobox[data-src="/api/options"]')
      end
    end

    describe 'with hint' do
      it 'renders hint text' do
        render_form { |f| f.combobox_field :gender, options: %w[Male Female], hint: 'Choose one' }
        assert @subject.has_css?('[part="hint"]', text: 'Choose one')
      end
    end

    describe 'with label override' do
      it 'renders custom label' do
        render_form do |f|
          f.combobox_field :gender, options: %w[Male Female], label: 'Custom Label'
        end
        assert @subject.has_css?('label', text: /Custom Label/)
      end
    end

    describe 'with multiple' do
      it 'renders multi-select combobox' do
        render_form { |f| f.combobox_field :gender, options: %w[Male Female], multiple: true }
        assert @subject.has_css?('pui-combobox[data-multiple]')
      end
    end
  end
end
