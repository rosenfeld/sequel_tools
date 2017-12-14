# frozen-string-literal: true

require_relative '../actions_manager'

class SequelTools::ActionsManager
  description = 'Populates an empty database with previously dumped schema' 
  Action.register :schema_load, description do |args, context|
    begin
      Action[:connect_db].run({}, context)
    rescue
      puts 'Database does not exist - aborting.'
      exit 1
    else
      schema_location = context[:config][:schema_location]
      unless File.exist? schema_location
        puts "Schema file '#{schema_location}' does not exist. Aborting."
        exit 1
      end
      context[:db] << File.read(schema_location)
    end
  end
end

