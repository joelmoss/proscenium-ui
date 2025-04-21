# frozen_string_literal: true

require 'test_helper'

class Proscenium::UI::Form::Fields::TextareaTest < ActiveSupport::TestCase
  def subject(...) = Proscenium::UI::Form.new(...)
  let(:user) { User.new name: 'Joel Moss' }
  view do
    subject user do |f|
      f.textarea_field :name
    end
  end

  it 'side loads the form and date css modules' do
    view

    assert_equal ["#{COMPONENTS_PATH}/form/index.css"], Proscenium::Importer.imported.keys
  end

  it 'has a label' do
    assert_match %r{^<div><span>Name</span></div>}, view.find('label').native.inner_html
  end

  it 'has a textarea with value' do
    assert_equal 'Joel Moss', view.find('textarea').text
  end
end
