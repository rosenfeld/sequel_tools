# frozen-string-literal: true

require_relative '../actions_manager'
require_relative 'schema_dump_postgres'
require_relative 'shell_postgres'

class SequelTools::ActionsManager
  Action.register :before_any_postgres, nil do |args, context|
    next if context[:before_any_postgres_processed]
    config = context[:config]
    config[:maintenancedb] = 'postgres' if config[:maintenancedb] == :default
    config[:jdbc_adapter] = 'postgresql' if RUBY_PLATFORM == 'java'
  end
end
