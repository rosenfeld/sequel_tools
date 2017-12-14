# frozen-string-literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sequel_tools/version'

Gem::Specification.new do |spec|
  spec.name          = 'sequel_tools'
  spec.version       = SequelTools::VERSION
  spec.authors       = ['Rodrigo Rosenfeld Rosas']
  spec.email         = ['rr.rosas@gmail.com']

  spec.summary       = %q{Add Rake tasks to manage Sequel migrations}
  spec.description   = <<~DESCRIPTION_END
    Offer tooling for common database operations, such as running Sequel migrations, store and
    load from the database schema, rollback, redo some migration, rerun all migrations, display
    applied and missing migrations. It allows integration with Rake, while being lazily evaluated
    to not slow down other Rake tasks. It's also configurable in order to support more actions
    and database vendors. Some tasks are currently implemented for PostgreSQL only for the time
    being out of the box. It should be possible to complement this gem with another one to
    support other database vendors, while taking advantage of the build blocks provided by this
    tool set.
  DESCRIPTION_END
  spec.homepage      = 'https://github.com/rosenfeld/sequel_tools'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^spec/})
  end
  #spec.bindir        = 'exe'
  #spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'sequel'
  spec.add_development_dependency 'pg'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
