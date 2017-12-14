# frozen-string-literal: true

require 'sequel'
require_relative '../actions_manager'
require_relative '../migration_utils'

class SequelTools::ActionsManager
  desc = 'Run specified migration down if not already applied'
  Action.register :down, desc, arg_names: [ :version ] do |args, context|
    MigrationUtils.apply_migration context, args[:version], :down
    Action[:schema_dump].run({}, context) if context[:config][:dump_schema_on_migrate]
  end
end

