# frozen_string_literal: true

require 'test_helper'

class Proscenium::UI::Form::Fields::BasicInputsTest < ActiveSupport::TestCase
  def self.it_behaves_like_field(type)
    describe "##{type}_field" do
      def subject(...) = Proscenium::UI::Form.new(...)

      input_type = type.to_s.dasherize

      let(:user) { User.new }

      view do
        subject user, action: '/' do |f|
          f.send :"#{type}_field", :name
        end
      end

      it 'side loads only the form css modules' do
        view

        assert_equal ["#{COMPONENTS_PATH}/form.css"], Proscenium::Importer.imported.keys
      end

      it "has a #{type} field" do
        assert view.has_field?('user[name]', type: input_type)
      end

      it 'has a label' do
        assert_equal 'Name', view.find('label').text
      end

      it 'renders label before input' do
        assert_match %r{^<div><span>Name</span>}, view.find('label').native.inner_html
      end

      with 'attribute name as a string' do
        view do
          subject user, action: '/' do |f|
            f.send :"#{type}_field", 'foo[]'
          end
        end

        it 'pass the name through as is' do
          assert view.has_field?('foo[]', type: input_type)
        end
      end

      with ':label' do
        view do
          subject user, action: '/' do |f|
            f.send :"#{type}_field", :name, label: 'Foobar'
          end
        end

        it 'overrides label' do
          assert_equal 'Foobar', view.find('label').text
        end
      end

      with ':class' do
        view do
          subject user, action: '/' do |f|
            f.send :"#{type}_field", :name, class: :my_class
          end
        end

        it 'appends class value to field wrapper' do
          assert_equal 'my_class', view.find('pui-field')[:class]
        end
      end

      with 'label: false' do
        view do
          subject user, action: '/' do |f|
            f.send :"#{type}_field", :name, label: false
          end
        end

        it 'omits label' do
          assert_empty view.find('label').text
        end
      end

      with 'model error' do
        let(:user) do
          User.new.tap do |u|
            u.errors.add :name, :invalid
          end
        end

        view do
          subject user, action: '/' do |f|
            f.send :"#{type}_field", :name
          end
        end

        it 'has data-field-error on wrapping div' do
          assert_not_nil view.find('pui-field')['data-field-error']
        end

        it 'shows error message' do
          assert_equal 'Nameis invalid', view.find('label').text
        end
      end

      with 'error option as ActiveModel::Error' do
        let(:user) do
          User.new.tap do |u|
            u.errors.add :name, :invalid
          end
        end

        view do
          subject user, action: '/' do |f|
            f.send :"#{type}_field", :name, error: f.model.errors.where(:name).first
          end
        end

        it 'shows error message' do
          assert_equal 'is invalid', view.find('label>div>span:last-child').text
        end
      end

      with 'error option as String' do
        let(:user) do
          User.new.tap do |u|
            u.errors.add :name, :invalid
          end
        end

        view do
          subject user, action: '/' do |f|
            f.send :"#{type}_field", :name, error: 'is foobar'
          end
        end

        it 'shows error message' do
          assert_equal 'is foobar', view.find('label>div>span:last-child').text
        end
      end

      with 'nested one-to-one attributes' do
        let(:user) do
          User.new address: Address.new(city: 'Chorley')
        end

        view do
          subject user, action: '/' do |f|
            f.send :"#{type}_field", :address, :city
          end
        end

        it 'translates label' do
          assert_equal 'City', view.find('label').text
        end

        it 'has a nested field' do
          assert view.has_field?('user[address][city]', type: input_type)
        end
      end

      with 'accepts_nested_attributes_for' do
        let(:author) do
          Author.new address: Address.new(city: 'Chorley')
        end

        view do
          subject author, action: '/' do |f|
            f.send :"#{type}_field", :address, :city
          end
        end

        it 'translates label' do
          assert_equal 'City', view.find('label').text
        end

        it 'has a nested field' do
          assert view.has_field?('author[address_attributes][city]', type: input_type)
        end
      end

      describe 'bang attributes' do
        with ':required!' do
          view do
            subject user, action: '/' do |f|
              f.send :"#{type}_field", :name, :required!
            end
          end

          it 'adds required attribute to input' do
            assert_empty view.find_field('Name', type: input_type)[:required]
          end
        end

        with 'required: true' do
          view do
            subject user, action: '/' do |f|
              f.send :"#{type}_field", :name, required: true
            end
          end

          it 'adds required attribute to input' do
            assert_empty view.find_field('Name', type: input_type)[:required]
          end
        end

        with ':required! and required: false' do
          view do
            subject user, action: '/' do |f|
              f.send :"#{type}_field", :name, :required!, required: false
            end
          end

          it 'expects required to be false' do
            assert_nil view.find_field('Name', type: input_type)[:required]
          end
        end
      end
    end
  end

  %i[text url time week month email color search password].each do |type|
    it_behaves_like_field type
  end

  describe '#hidden_field' do
    let(:user) { User.new }
    view do
      subject user, url: '/' do |f|
        f.hidden_field :name
      end
    end

    it 'has a hidden field' do
      assert view.has_field?('user[name]', type: :hidden)
    end

    it 'has no label' do
      assert_not view.has_css?('label')
    end

    with 'value from model' do
      let(:user) { User.new name: 'Joel Moss' }

      it 'has a value' do
        assert view.has_field?('user[name]', type: :hidden, with: 'Joel Moss')
      end
    end
  end
end
