# frozen-string-literal: true

require 'bundler/setup'

module SpecHelpers
  CACHE = {}

  def sample_project_root
    CACHE[:sample_project_root] ||= File.expand_path 'sample_project', __dir__
  end

  def schema_location
    CACHE[:schema_location] ||= File.join migrations_path, 'schema.sql'
  end

  def migrations_path
    CACHE[:migrations_path] ||= File.join sample_project_root, 'db/migrations'
  end

  def seeds_location
    CACHE[:seeds_location] ||= File.join sample_project_root, 'db/seeds.rb'
  end

  def db
    return CACHE[:db] if CACHE[:db]
    require 'sequel'
    CACHE[:db] = make_connection 'postgres://sequel_tools_user@localhost/sequel_tools_test'
  end

  def make_connection(uri)
    result = Sequel.connect uri
    if ENV['FORK_RAKE']
      result.extension :connection_validator
      result.pool.connection_validation_timeout = -1
    end
    result
  end

  def with_dbtest
    require 'sequel'
    dbtest = make_connection 'postgres://sequel_tools_user@localhost/sequel_tools_test_test'
    yield dbtest
    dbtest.disconnect
  end

  def drop_test_database_if_exists
    db << 'drop database if exists sequel_tools_test_test'
  end

  def rake_runner
    require_relative 'rake_runner'
    RakeRunner.instance
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include SpecHelpers
  config.before(:suite) do
    require 'fileutils'
    FileUtils.mkdir_p File.join(__dir__, 'sample_project/db/migrations')
  end
end

require 'rspec/expectations'

RSpec::Matchers.define :be_successful do
  match do |action_result|
    action_result.success == true
  end

  failure_message do |action_result|
    msg = [ "Task '#{action_result.name}' failed with status '#{action_result.status}'" ]
    msg << "\nstdout:\n" << action_result.stdout unless action_result.stdout.empty?
    msg << "\nstderr:\n" << action_result.stderr unless action_result.stderr.empty?
    msg.join "\n"
  end
end
