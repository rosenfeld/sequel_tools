# frozen-string-literal: true

require 'sequel'
require_relative '../actions_manager'

SequelTools::ActionsManager::Action.register :connect_db, nil do |args, context|
  next if context[:db]
  context[:db] = Sequel.connect context[:uri_builder].call context[:config]
end

