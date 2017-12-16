# frozen-string-literal: true

require_relative '../actions_manager'

class SequelTools::ActionsManager
  desc = 'Creates a new migration'
  Action.register :new_migration, desc, arg_names: [ :name ] do |args, context|
    (puts 'Migration name is missing - aborting'; exit 1) unless name = args[:name]
    require 'time'
    migrations_path = context[:config][:migrations_location]
    filename = "#{migrations_path}/#{Time.now.strftime '%Y%m%d%H%M%S'}_#{name}.rb"
    File.write filename, <<~MIGRATIONS_TEMPLATE_END
      # documentation available at http://sequel.jeremyevans.net/rdoc/files/doc/migration_rdoc.html
      Sequel.migration do
        change do
          # create_table(:table_name) do
          #   primary_key :id
          #   String :name, null: false
          # end
        end
        # or call up{} and down{}
      end
    MIGRATIONS_TEMPLATE_END
    puts "The new migration file was created under #{filename.inspect}"
  end
end


