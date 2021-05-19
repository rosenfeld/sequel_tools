# frozen-string-literal: true

require 'sequel_tools/version'

module SequelTools
  DEFAULT_CONFIG = {
    project_root: nil,
    pg_dump: 'pg_dump', # command used to run pg_dump
    psql: 'psql', # command used to run psql
    maintenancedb: :default, # DB to connect to for creating/dropping databases
    migrations_location: 'db/migrations',
    schema_location: 'db/migrations/schema.sql',
    seeds_location: 'db/seeds.rb',
    dbname: nil,
    dbhost: 'localhost',
    dbadapter: 'postgres',
    dbport: nil,
    username: nil,
    password: nil,
    dump_schema_on_migrate: false,
    log_level: nil,
    sql_log_level: :debug,
    migrations_table: nil,
  } # unfrozen on purpose so that one might want to update the defaults

  REQUIRED_KEYS = [ :project_root, :dbadapter, :dbname, :username ]
  class MissingConfigError < StandardError; end
  def self.base_config(extra_config = {})
    config = DEFAULT_CONFIG.merge extra_config
    REQUIRED_KEYS.each do |key|
      raise MissingConfigError, "Expected value for #{key} config is missing" if config[key].nil?
    end
    [:migrations_location, :schema_location, :seeds_location].each do |k|
      config[k] = File.expand_path config[k], config[:project_root]
    end
    config
  end

  def self.inject_rake_tasks(config = {}, rake_context)
    require_relative 'sequel_tools/actions_manager'
    require_relative 'sequel_tools/all_actions'
    actions_manager = ActionsManager.new config
    actions_manager.load_all
    actions_manager.export_as_rake_tasks rake_context
  end

  def self.suppress_java_output
    return yield unless RUBY_PLATFORM == 'java'
    require 'java'
    require 'stringio'
    old_err = java.lang.System.err
    java.lang.System.err = java.io.PrintStream.new(StringIO.new.to_outputstream)
    yield
  ensure
    java.lang.System.err = old_err if RUBY_PLATFORM == 'java'
  end
end
