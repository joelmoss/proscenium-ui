# frozen_string_literal: true

require 'test_helper'

class Proscenium::UI::Form::Fields::RichTextareaTest < ActiveSupport::TestCase
  def subject(...) = Proscenium::UI::Form.new(...)
  let(:user) { User.new name: 'Joel Moss' }
  view do
    subject user do |f|
      f.rich_textarea_field :name
    end
  end

  it 'side loads the form and date css modules' do
    view

    imports = Proscenium::Importer.imported.keys
    assert_equal ["#{COMPONENTS_PATH}/form.css",
                  "#{COMPONENTS_PATH}/form/fields/rich_textarea.js",
                  "#{COMPONENTS_PATH}/form/fields/rich_textarea.css"], imports
  end

  it 'has a label' do
    assert_equal 'Name', view.find('label').text
  end

  it 'has a trix-editor element' do
    assert view.has_css?('trix-editor[input^=user_name]')
  end

  it 'has a hidden input' do
    name = 'user[name]'
    assert view.has_field?(name, type: :hidden)
    assert_equal 'Joel Moss', view.find_field(name, type: :hidden).value
  end
end
