# frozen-string-literal: true

require_relative '../actions_manager'

class SequelTools::ActionsManager
  Action.register :schema_dump, 'Store current db schema' do |args, context|
    begin
      Action[:connect_db].run({}, context)
    rescue
      puts 'Database does not exist - aborting.'
      exit 1
    else
      c = context[:config]
      unless action = Action[:"schema_dump_#{c[:dbadapter]}"]
        puts "Dumping the db schema is not currently supported for #{c[:dbadapter]}. Aborting"
        exit 1
      end
      action.run({}, context)
    end
  end
end

