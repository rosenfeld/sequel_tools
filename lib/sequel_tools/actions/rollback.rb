# frozen-string-literal: true

require 'sequel'
require_relative '../actions_manager'
require_relative '../migration_utils'

class SequelTools::ActionsManager
  Action.register :rollback, 'Rollback last applied migration' do |args, context|
    unless last_found_migration = MigrationUtils.last_found_migration(context)
      puts 'No existing migrations are applied - cannot rollback'
      exit 1
    end
    MigrationUtils.apply_migration context, last_found_migration, :down
    Action[:schema_dump].run({}, context) if context[:config][:dump_schema_on_migrate]
  end
end

