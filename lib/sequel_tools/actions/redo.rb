# frozen-string-literal: true

require 'sequel'
require_relative '../actions_manager'

class SequelTools::ActionsManager
  desc = 'Run specified migration down and up (redo)'
  Action.register :redo, desc, arg_names: [ :version ] do |args, context|
    Action[:down].run(args, context)
    Action[:up].run(args, context)
    Action[:schema_dump].run({}, context) if context[:config][:dump_schema_on_migrate]
  end
end

