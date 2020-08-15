# frozen-string-literal: true

require 'sequel'
require_relative '../actions_manager'

class SequelTools::ActionsManager
  Action.register :create, 'Create database' do |args, context|
    begin
      Action[:connect_db].run({}, context)
    rescue
      c = context[:config]
      db = Sequel.connect context[:uri_builder].call(c, c[:maintenancedb])
      db << "create database #{c[:dbname]}"
      db.disconnect
      Action[:connect_db].run({}, context)
      context[:db].log_info "Created database '#{c[:dbname]}'"
    else
      puts 'Database already exists - aborting'
    end
  end
end

