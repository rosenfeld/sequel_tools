# frozen-string-literal: true

require 'sequel'
require_relative '../actions_manager'
require_relative '../migration_utils'

class SequelTools::ActionsManager
  Action.register :version, 'Displays current version' do |args, context|
    puts MigrationUtils.current_version(context) || 'No migrations applied'
  end
end


