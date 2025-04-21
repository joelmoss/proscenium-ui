# frozen_string_literal: true

require 'test_helper'

class Proscenium::UI::Form::Fields::CheckboxTest < ActiveSupport::TestCase
  def subject(...) = Proscenium::UI::Form.new(...)
  let(:user) { User.new }
  view do
    subject user do |f|
      f.checkbox_field :active
    end
  end

  it 'side loads only the form css modules' do
    view

    assert_equal ["#{COMPONENTS_PATH}/form.css"], Proscenium::Importer.imported.keys
  end

  it 'has an unchecked checkbox input' do
    assert view.has_field?('user[active]', type: :checkbox, checked: false)
  end

  it 'has a hidden input with the falsey value' do
    assert_equal '0', view.find_field('user[active]', type: :hidden)[:value]
  end

  it 'is checked' do
    user.active = true

    assert view.has_field?('user[active]', type: :checkbox, checked: true)
  end

  it 'renders label after input' do
    # rubocop:disable Layout/LineLength
    assert_equal %(
      <label><input name="user[active]" type="hidden" value="0"><input name="user[active]" type="checkbox" value="1"><div><span>Active</span></div></label>
      ).strip, view.find('label').native.to_html
    # rubocop:enable Layout/LineLength
  end

  with ':label' do
    view do
      subject user do |f|
        f.checkbox_field :active, label: 'Foobar'
      end
    end

    it 'overrides label' do
      assert_equal 'Foobar', view.find('label').text
    end
  end

  with 'predicate? method' do
    view do
      subject user do |f|
        f.checkbox_field :active?
      end
    end

    it 'overrides label' do
      user.active = true

      assert_equal 'Active?', view.find('label').text
      assert view.has_field?('user[active]', type: :checkbox, checked: true)
    end
  end

  with ':checked' do
    view do
      subject user do |f|
        f.checkbox_field :active?, checked: true
      end
    end

    it 'overrides label' do
      assert view.has_field?('user[active]', type: :checkbox, checked: true)
    end
  end

  with ':checked_value and :unchecked_value' do
    view do
      subject user do |f|
        f.checkbox_field :active, checked_value: 'yes'
        f.checkbox_field :active, unchecked_value: 'no'
      end
    end

    it 'overrides values' do
      assert view.has_css?('[name="user[active]"][type="hidden"][value="no"]', visible: false)
      assert view.has_css?('[name="user[active]"][value="yes"]')
    end
  end
end
