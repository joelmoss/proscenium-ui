# frozen_string_literal: true

module Views
  class Forms::Basic < Application
    def view_template
      h1 { 'Forms index' }

      Proscenium::UI::Form.new(user) do |f|
        f.text_field :name, required: true
        f.email_field :email
        f.password_field :password
        f.select_field :role, options: %w[admin user]
        f.submit 'Create User'
      end
    end
  end
end
