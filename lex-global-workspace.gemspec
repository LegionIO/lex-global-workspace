# frozen_string_literal: true

require_relative 'lib/legion/extensions/global_workspace/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-global-workspace'
  spec.version       = Legion::Extensions::GlobalWorkspace::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Global Workspace'
  spec.description   = "Baars' Global Workspace Theory for brain-modeled agentic AI — information " \
                       'competes for access to a limited-capacity workspace; winners are broadcast to ' \
                       'all subscribed cognitive subsystems, implementing a computational model of ' \
                       'conscious access and attentional bottleneck.'
  spec.homepage      = 'https://github.com/LegionIO/lex-global-workspace'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']          = spec.homepage
  spec.metadata['source_code_uri']       = 'https://github.com/LegionIO/lex-global-workspace'
  spec.metadata['documentation_uri']     = 'https://github.com/LegionIO/lex-global-workspace'
  spec.metadata['changelog_uri']         = 'https://github.com/LegionIO/lex-global-workspace'
  spec.metadata['bug_tracker_uri']       = 'https://github.com/LegionIO/lex-global-workspace/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob('{lib,spec}/**/*') + %w[lex-global-workspace.gemspec Gemfile]
  end
  spec.require_paths = ['lib']
end
