# frozen_string_literal: true

require 'test_helper'

class Proscenium::UI::FormTest < ActiveSupport::TestCase
  let(:user) { User.new }
  view { subject user }

  it 'side loads CSS' do
    view
    assert_equal ["#{COMPONENTS_PATH}/form/index.css"], Proscenium::Importer.imported.keys
  end

  it 'has an action attribute' do
    assert_equal '/users', view.find('form')[:action]
  end

  context 'default method' do
    it 'has a default method attribute' do
      assert_equal 'post', view.find('form')[:method]
    end

    it 'does not have a hidden _method field' do
      assert_not view.has_field?('_method', type: :hidden)
    end
  end

  context 'method: :get' do
    view { subject user, method: :get }

    it 'has a method attribute' do
      assert_equal 'get', view.find('form')[:method]
    end

    it 'does not have a hidden _method field' do
      assert_not view.has_field?('_method', type: :hidden)
    end
  end

  context 'method: :patch' do
    view { subject user, method: :patch }

    it 'form[method] == post' do
      assert_equal 'post', view.find('form')[:method]
    end

    it 'has a hidden _method field' do
      assert_equal 'patch', view.find('input[name=_method]', visible: :hidden)[:value]
    end
  end

  context 'persisted model record' do
    let(:user) { User.create! name: 'Joel' }

    it 'has a hidden _method field' do
      assert_equal 'patch', view.find('input[name=_method]', visible: :hidden)[:value]
    end
  end

  it 'has an authenticity_token field' do
    assert view.has_field?('authenticity_token', type: :hidden)
  end

  context ':action' do
    view { subject user, action: '/' }

    it 'sets form action to URL' do
      assert_equal '/', view.find('form')[:action]
    end
  end

  context '**attributes' do
    view { subject user, class: 'myform' }

    it 'passes attributes to form' do
      assert view.has_css?('form.myform')
    end
  end

  describe '#submit' do
    view do
      subject user do |f|
        f.submit 'Save'
      end
    end

    it 'has a submit button' do
      assert view.has_button?('Save')
    end
  end
end
