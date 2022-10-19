# frozen-string-literal: true

require 'sequel_tools/version'
require 'sequel/core'
require 'uri'

module SequelTools
  DEFAULT_CONFIG = {
    project_root: Dir.pwd,
    pg_dump: 'pg_dump', # command used to run pg_dump
    psql: 'psql', # command used to run psql
    maintenancedb: :default, # DB to connect to for creating/dropping databases
    migrations_location: 'db/migrations',
    schema_location: 'db/migrations/schema.sql',
    seeds_location: 'db/seeds.rb',
    db_url: nil,
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
    extra_tables_in_dump: nil,
  } # unfrozen on purpose so that one might want to update the defaults

  class MissingConfigError < StandardError; end
  def self.base_config(extra_config = {})
    config = DEFAULT_CONFIG.merge extra_config
    unless config[:db_url] || (config[:dbadapter && config[:dbname]])
      raise MissingConfigError, "Must provide either :db_url or :dbadapter and :dbname config options"
    end

    if config[:db_url]
      db = Sequel.connect(config[:db_url], test: false, keep_reference: false)
      if RUBY_PLATFORM == 'java'
        uri = URI.parse(config[:db_url][/\Ajdbc:(.+)/, 1])
        config[:dbadapter] = uri.scheme
        config[:dbname] = uri.path[/\/(.+)/, 1]
      else
        config[:dbadapter] = db.opts[:adapter]
        config[:dbname] = db.opts[:database]
      end
      config[:username] = db.opts[:user]
      config[:password] = db.opts[:password]
    end

    [:migrations_location, :schema_location, :seeds_location].each do |k|
      config[k] = File.expand_path config[k], config[:project_root]
    end
    config
  end

  def self.inject_rake_tasks(config = {}, rake_context)
    require_relative 'sequel_tools/actions_manager'
    require_relative 'sequel_tools/all_actions'
    actions_manager = ActionsManager.new base_config(config)
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
