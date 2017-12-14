# frozen-string-literal: true

require 'sequel'
require_relative '../actions_manager'

class SequelTools::ActionsManager
  desc = 'Migrate to specified version (last by default)'
  Action.register :migrate, desc, arg_names: [ :version ] do |args, context|
    Action[:connect_db].run({}, context)
    db = context[:db]
    config = context[:config]
    Sequel.extension :migration unless Sequel.respond_to? :migration
    options = {}
    options[:target] = args[:version].to_i if args[:version]
    Sequel::Migrator.run db, config[:db_migrations_location], options
    Action[:schema_dump].run({}, context) if config[:dump_schema_on_migrate]
  end
end

