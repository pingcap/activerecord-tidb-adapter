# frozen_string_literal: true

require_relative 'lib/version'

Gem::Specification.new do |spec|
  spec.name          = 'activerecord-tidb-adapter'
  spec.version       = ActiveRecord::TIDB_ADAPTER_VERSION
  spec.authors       = ['Hooopo Wang']
  spec.email         = ['hoooopo@gmail.com']

  spec.summary       = 'TiDB adapter for ActiveRecord.'
  spec.description   = 'Allows the use of TiDB as a backend for ActiveRecord and Rails apps.'
  spec.homepage      = 'https://github.com/pingcap/activerecord-tidb-adapter'
  spec.license       = 'Apache-2.0'
  spec.required_ruby_version = '>= 2.4.0'

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'https://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/pingcap/activerecord-tidb-adapter'
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '~> 5.2'
  spec.add_dependency 'mysql2'

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
