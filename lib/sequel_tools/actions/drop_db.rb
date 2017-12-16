# frozen-string-literal: true

require 'sequel'
require_relative '../actions_manager'

class SequelTools::ActionsManager
  Action.register :drop, 'Drop database' do |args, context|
    begin
      Action[:connect_db].run({}, context)
    rescue
      puts 'Database does not exist - aborting.'
      exit 1
    else
      (old_db = context.delete :db).disconnect
      c = context[:config]
      db = Sequel.connect context[:uri_builder].call(c, c[:maintenancedb])
      db << "drop database #{c[:dbname]}"
      db.disconnect
      old_db.log_info "Dropped database '#{c[:dbname]}'"
    end
  end
end

