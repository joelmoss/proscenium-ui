# frozen_string_literal: true

require 'test_helper'

class Proscenium::UI::Form::Fields::TelTest < ActiveSupport::TestCase
  def subject(...) = Proscenium::UI::Form.new(...)
  let(:user) { User.new name: 'Joel Moss' }
  view do
    subject user do |f|
      f.tel_field :phone
    end
  end

  it 'has a select input' do
    assert view.has_css?('pui-tel-field select > option:first-child[value="AF"]')
  end

  it 'has a text input' do
    assert view.has_css?('pui-tel-field input[type="text"][name="user[phone]"]')
  end

  it 'country defaults to US' do
    assert view.has_css?('pui-tel-field select>option[selected="selected"][value="US"]')
  end

  with ':default_country' do
    view do
      subject user do |f|
        f.tel_field :phone, default_country: :gb
      end
    end

    it 'country == GB' do
      assert view.has_css?('pui-tel-field select>option[selected="selected"][value="GB"]')
    end
  end
end
