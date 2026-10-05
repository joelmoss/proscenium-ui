# frozen_string_literal: true

require_relative 'lib/proscenium/ui/version'

Gem::Specification.new do |spec|
  spec.name        = 'proscenium-ui'
  spec.version     = Proscenium::UI::VERSION
  spec.authors     = ['Joel Moss']
  spec.email       = ['joel@developwithstyle.com']
  spec.homepage    = 'https://proscenium.rocks'
  spec.summary     = 'A full featured UI library for Rails.'
  spec.license     = 'MIT'
  spec.required_ruby_version = '>= 3.3.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/joelmoss/proscenium-ui'
  spec.metadata['changelog_uri'] = 'https://github.com/joelmoss/proscenium-ui/releases'
  spec.metadata['rubygems_mfa_required'] = 'true'
  # Proscenium installs package.json's dependencies for this gem (`bundle exec proscenium install`).
  spec.metadata['proscenium.dependencies'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    # config/props.css: lib/proscenium/ui/form/index.css imports it; the rest of config/ is the
    # demo app's.
    Dir['{lib}/**/*', 'config/props.css', 'MIT-LICENSE', 'README.md', 'package.json']
  end

  spec.add_dependency 'countries', '~> 8.1.0'
  spec.add_dependency 'literal', '~> 1.9.0'
  spec.add_dependency 'phonelib', '~> 0.10.8'
  spec.add_dependency 'proscenium-phlex', '~> 0.6.0'
  spec.add_dependency 'rails', ['>= 7.2.0', '< 9.0']
end
