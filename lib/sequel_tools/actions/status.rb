# frozen-string-literal: true

require 'sequel'
require_relative '../actions_manager'
require_relative '../migration_utils'

class SequelTools::ActionsManager
  description = 'Show migrations status (applied and missing in migrations path vs unapplied)'
  Action.register :status, description do |args, context|
    unapplied, files_missing = MigrationUtils.migrations_differences context
    path = context[:config][:db_migrations_location]
    unless files_missing.empty?
      puts "The following migrations were applied to the database but can't be found in #{path}:"
      puts files_missing.map{|fn| "  - #{fn}" }.join("\n")
      puts
    end
    if unapplied.empty?
      puts 'No pending migrations in the database' if files_missing.empty?
    else
      puts 'Unapplied migrations:'
      puts unapplied.map{|fn| "  - #{fn}" }.join("\n")
      puts
    end
  end
end

