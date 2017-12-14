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
    else
      puts 'Database already exists - aborting'
      exit 1
    end
  end
end

