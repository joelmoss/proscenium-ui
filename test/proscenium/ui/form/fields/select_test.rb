# frozen_string_literal: true

require 'test_helper'

class Proscenium::UI::Form::Fields::SelectTest < ActiveSupport::TestCase
  def subject(...) = Proscenium::UI::Form.new(...)
  let(:user) { User.new }

  describe 'assets' do
    view do
      subject user, url: '/' do |f|
        f.select_field :gender
      end
    end

    it 'side loads the form and select css modules' do
      view

      imports = Proscenium::Importer.imported.keys
      assert_equal ["#{COMPONENTS_PATH}/form/index.css",
                    "#{COMPONENTS_PATH}/form/fields/select.jsx",
                    "#{COMPONENTS_PATH}/form/fields/select.module.css"], imports
    end
  end

  with 'enum attribute' do
    view do
      subject user, url: '/' do |f|
        f.select_field :gender
      end
    end

    it 'uses enum values for options' do
      assert view.has_select?('Gender', options: ['', 'Male', 'Female', 'Other'])
    end

    with 'persisted value' do
      let(:user) { User.new gender: :male }

      it 'uses persisted value' do
        assert view.has_select?('Gender', options: ['', 'Male', 'Female', 'Other'],
                                          selected: 'Male')
      end
    end

    with 'default value' do
      view do
        subject user, url: '/' do |f|
          f.select_field :gender_with_db_default
          f.select_field :gender_with_code_default
        end
      end

      it 'uses default enum value' do
        assert view.has_select?('Gender with db default', options: %w[Male Female Other],
                                                          selected: 'Male')
        assert view.has_select?('Gender with code default', options: %w[Male Female Other],
                                                            selected: 'Female')
      end
    end
  end

  with 'belongs_to association attribute' do
    before do
      User.create! [{ name: 'Joel Moss' }, { name: 'Eve Moss' }]
    end

    let(:event) { Event.new }
    view do
      subject event do |f|
        f.select_field :user
      end
    end

    it 'uses association values for options' do
      assert view.has_select?('User', options: ['', 'Joel Moss', 'Eve Moss'])
    end

    it 'has no value selected' do
      assert view.has_select?('User', options: ['', 'Joel Moss', 'Eve Moss'], selected: nil)
    end

    it 'has correct input name' do
      assert_equal 'event[user_id]', view.find_field('User', type: :select)[:name]
    end

    with 'persisted value' do
      let(:event) { Event.new user: User.first }

      it 'uses persisted value' do
        assert view.has_select?('User', options: ['', 'Joel Moss', 'Eve Moss'],
                                        selected: 'Joel Moss')
      end
    end
  end

  with 'a block' do
    view do
      Class.new(Phlex::HTML) do
        def initialize(user) # rubocop:disable Lint/MissingSuper
          @user = user
        end

        def view_template
          Proscenium::UI::Form(@user) do |f|
            f.select_field :gender do
              option { 'Bloke' }
              option { 'Chick' }
            end
          end
        end
      end.new(user)
    end

    it 'renders block in place of options' do
      assert view.has_select?('user[gender]', options: %w[Bloke Chick])
    end
  end

  with 'options: Array<String>' do
    view do
      subject user do |f|
        f.select_field :tags, options: %w[1tag 2tag]
      end
    end

    it 'uses given options' do
      assert_equal([%w[1tag 1tag], %w[2tag 2tag]],
                   view.find_css('option').map { |e| [e.text, e[:value]] })
    end
  end

  with 'options: Array<Array>' do
    view do
      subject user do |f|
        f.select_field :tags, options: [['Tag One', '1tag'], ['Tag two', '2tag']]
      end
    end

    it 'uses given options' do
      options = view.find_css('option').map { |e| [e.text, e[:value]] }
      assert_equal [['Tag One', '1tag'], ['Tag two', '2tag']], options
    end
  end

  with 'options: Enumerable' do
    view do
      subject user do |f|
        f.select_field :tags, options: %w[1tag 2tag]
      end
    end

    it 'uses given options' do
      assert view.has_select?('user[tag_ids][]', options: %w[1tag 2tag])
    end
  end

  describe 'multiple values' do
    before do
      Tag.create! [{ name: 'tag1' }, { name: 'tag2' }]
    end

    view do
      subject user do |f|
        f.select_field :tags
      end
    end

    it 'renders select of tags' do
      assert view.has_select?('user[tag_ids][]', options: %w[tag1 tag2], selected: nil)
    end

    it 'defines :multiple attribute' do
      assert_predicate view.find_field('Tags', type: :select)[:multiple], :present?
    end

    with 'persisted value' do
      let(:user) do
        User.create! name: 'Joel Moss',
                     tags: Tag.where(name: 'tag1')
      end

      it 'selects persisted tags' do
        assert view.has_select?('Tags', options: %w[tag1 tag2], selected: 'tag1')
      end
    end
  end

  describe 'bang attributes' do
    with ':required!' do
      view do
        subject user do |f|
          f.select_field :gender, :required!
        end
      end

      it 'adds required attribute to input' do
        assert_empty view.find_field('Gender', type: :select)[:required]
      end
    end

    with 'required: true' do
      view do
        subject user do |f|
          f.select_field :gender, required: true
        end
      end

      it 'adds required attribute to input' do
        assert_empty view.find_field('Gender', type: :select)[:required]
      end
    end

    with ':required! and required: false' do
      view do
        subject user do |f|
          f.select_field :gender, :required!, required: false
        end
      end

      it 'expects required to be false' do
        assert_nil view.find_field('Gender', type: :select)[:required]
      end
    end
  end

  with ':required! and no value' do
    view do
      subject user do |f|
        f.select_field :gender, :required!
      end
    end

    it 'includes empty option' do
      assert view.has_select?('Gender', options: ['', 'Male', 'Female', 'Other'])
    end
  end

  with 'include_blank: false' do
    view do
      subject user do |f|
        f.select_field :gender, include_blank: false
      end
    end

    it 'does not include empty option' do
      assert view.has_select?('Gender', options: %w[Male Female Other])
    end
  end

  with 'include_blank: String' do
    view do
      subject user do |f|
        f.select_field :gender, include_blank: 'Select'
      end
    end

    it 'includes empty option with text' do
      assert view.has_select?('Gender', options: %w[Select Male Female Other])
    end
  end

  with ':label' do
    view do
      subject user, url: '/' do |f|
        f.select_field :gender, label: 'Foobar'
      end
    end

    it 'overrides label' do
      assert_match %r{^<div><span>Foobar</span></div>}, view.find('label').native.inner_html
    end
  end

  with ':class' do
    view do
      subject user, url: '/' do |f|
        f.select_field :gender, class: 'my_class'
      end
    end

    it 'appends class value to field wrapper' do
      assert_equal 'field-f68c91b1 my_class', view.find('pui-field')[:class]
    end
  end

  with ':typeahead!' do
    before do
      Tag.create! [{ name: 'tag1' }, { name: 'tag2' }]
    end

    view do
      subject user do |f|
        f.select_field :tags, :typeahead!
      end
    end

    it 'should render a component div' do
      assert view.has_no_selector?('select')
      assert view.has_selector?('[data-proscenium-component-path]')
    end

    # FIXME: react component manefr failing in trest env
    # describe 'javascript' do
    #   include Capybara::DSL

    #   it 'renders' do
    #     visit '/component_previews/_/hue/app/components/form/previews/select_typeahead'

    #     expect(page.has_button?('open menu', enable_aria_label: true)).to be_truthy
    #   end
    # end
  end
end
