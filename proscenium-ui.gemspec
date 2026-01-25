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
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/joelmoss/proscenium-ui'
  spec.metadata['changelog_uri'] = 'https://github.com/joelmoss/proscenium-ui/releases'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{lib}/**/*', 'MIT-LICENSE', 'README.md']
  end

  spec.add_dependency 'countries', '~> 8.1.0'
  spec.add_dependency 'literal', '~> 1.8.1'
  spec.add_dependency 'phonelib', '~> 0.10.8'
  spec.add_dependency 'proscenium-phlex', '~> 0.6.0'
  spec.add_dependency 'rails', ['>= 7.1.0', '< 9.0']
end
