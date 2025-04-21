# frozen_string_literal: true

require 'test_helper'

class Proscenium::UI::Form::Fields::RadioInputTest < ActiveSupport::TestCase
  def subject(...) = Proscenium::UI::Form.new(...)
  let(:user) { User.new }

  view do
    subject user do |f|
      f.radio_field :role, value: :admin
    end
  end

  it 'side loads only the form css modules' do
    view

    assert_equal ["#{COMPONENTS_PATH}/form.css"], Proscenium::Importer.imported.keys
  end

  it 'has a radio input with the provided value' do
    assert_equal 'admin', view.find_field('user[role]', type: :radio)[:value]
  end

  it 'is checked' do
    user.role = :admin

    assert view.has_field?('user[role]', checked: true)
  end

  it 'has a label with the value' do
    assert_equal 'Admin', view.find('label>span').text
  end

  with 'label attribute' do
    view do
      subject user do |f|
        f.radio_field :role, value: :admin, label: 'Administrator'
      end
    end

    it 'has a label with the value' do
      assert_equal 'Administrator', view.find('label>span').text
    end
  end
end
