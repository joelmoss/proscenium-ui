# frozen_string_literal: true

require_relative 'lib/proscenium/ui/version'

Gem::Specification.new do |spec|
  spec.name        = 'proscenium-ui'
  spec.version     = Proscenium::UI::VERSION
  spec.authors     = ['Joel Moss']
  spec.email       = ['joel@developwithstyle.com']
  spec.homepage    = 'https://proscenium.rocks'
  spec.summary     = 'A full featured UI library for Rails.'
  spec.description = 'A full featured UI library for Rails.'
  spec.license     = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/joelmoss/proscenium-ui'
  spec.metadata['changelog_uri'] = 'https://github.com/joelmoss/proscenium-ui/releases'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'countries', '~> 7.1.1'
  spec.add_dependency 'literal', '~> 1.7.1'
  spec.add_dependency 'phonelib', '~> 0.10.8'
  spec.add_dependency 'proscenium', '0.19.0.beta17'
  spec.add_dependency 'rails', '~> 8.0.2'
end
