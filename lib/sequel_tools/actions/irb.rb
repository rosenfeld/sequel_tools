# frozen-string-literal: true

require_relative '../actions_manager'

class SequelTools::ActionsManager
  description = "Opens an IRB session started as 'sequel uri_to_database' (DB is available to irb)"
  Action.register :irb, description do |args, context|
    # This code does the job, but for some reason the test will timeout under JRuby
    #config = context[:config]
    #uri = context[:uri_builder][config]
    #exec "bundle exec sequel #{uri}"

    Action[:connect_db].run({}, context)
    require 'irb'
    ::DB = context[:db]
    ARGV.clear
    puts 'Your database is stored in DB...'
    IRB.start
  end
end
