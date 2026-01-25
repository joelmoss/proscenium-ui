# frozen_string_literal: true

require 'test_helper'

describe Proscenium::UI::Form do
  let(:user) { User.new }
  render_subject { [user, foo: :bar] }

  it 'side loads CSS' do
    render_subject user
    assert_equal ["#{COMPONENTS_PATH}/form/index.css"], Proscenium::Importer.imported.keys
  end

  it 'has an action attribute' do
    assert_equal '/users', find('form')[:action]
  end

  context 'default method' do
    it 'has a default method attribute' do
      assert_equal 'post', find('form')[:method]
    end

    it 'does not have a hidden _method field' do
      assert_no_field('_method', type: :hidden)
    end
  end

  context 'method: :get' do
    render_subject { [user, method: :get] }

    it 'has a method attribute' do
      assert_equal 'get', find('form')[:method]
    end

    it 'does not have a hidden _method field' do
      assert_no_field('_method', type: :hidden)
    end
  end

  context 'method: :patch' do
    render_subject { [user, method: :patch] }

    it 'form[method] == post' do
      assert_equal 'post', find('form')[:method]
    end

    it 'has a hidden _method field' do
      assert_equal 'patch', find('input[name=_method]', visible: :hidden)[:value]
    end
  end

  context 'persisted model record' do
    let(:user) { User.create! name: 'Joel' }

    it 'has a hidden _method field' do
      assert_equal 'patch', find('input[name=_method]', visible: :hidden)[:value]
    end
  end

  it 'has an authenticity_token field' do
    assert_field('authenticity_token', type: :hidden)
  end

  context ':action' do
    render_subject { [user, action: '/'] }

    it 'sets form action to URL' do
      assert_equal '/', find('form')[:action]
    end
  end

  context '**attributes' do
    render_subject { [user, class: 'myform'] }

    it 'passes attributes to form' do
      assert_css 'form.myform'
    end
  end

  describe '#submit' do
    render_subject do
      [user, { action: '/' }, ->(f) { f.submit 'Save' }]
    end

    it 'has a submit button' do
      assert_button 'Save'
    end
  end
end
