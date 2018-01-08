# frozen-string-literal: true

require 'sequel'
require_relative '../actions_manager'
require_relative '../sequel_tools_logger'

SequelTools::ActionsManager::Action.register :connect_db, nil do |args, context|
  next if context[:db]
  config = context[:config]
  context[:db] = db = SequelTools.suppress_java_output do
    Sequel.connect context[:uri_builder].call(config), test: true
  end
  db.sql_log_level = config[:sql_log_level]
  db.log_connection_info = false
  next unless log_level = config[:log_level]
  require 'logger'
  db.logger = SequelTools::SequelToolsLogger.new(STDOUT, log_level)
end

