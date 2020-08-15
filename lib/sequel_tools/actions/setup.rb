# frozen-string-literal: true

require_relative '../actions_manager'

class SequelTools::ActionsManager
  description = 'Creates and populates a database with previously dumped schema and seeds'
  Action.register :setup, description do |args, context|
    begin
      Action[:connect_db].run({}, context)
    rescue
      Action[:create].run({}, context)
      Action[:schema_load].run({}, context)
      Action[:seed].run({}, context)
    else
      puts 'Database already exists - aborting.'
    end
  end
end

