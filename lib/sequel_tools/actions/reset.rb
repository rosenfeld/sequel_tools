# frozen-string-literal: true

require_relative '../actions_manager'

class SequelTools::ActionsManager
  desc = 'Recreate database from scratch by running all migrations and seeds in a new database'
  Action.register :reset, desc, arg_names: [ :version ] do |args, context|
    begin
      Action[:drop].run({}, context)
    rescue
    end
    Action[:create].run({}, context)
    Action[:migrate].run({}, context)
    Action[:seed].run({}, context)
  end
end


