# frozen-string-literal: true

require_relative '../actions_manager'

class SequelTools::ActionsManager
  Action.register :seed, 'Load seeds from seeds.rb' do |args, context|
    begin
      Action[:connect_db].run({}, context)
    rescue
      puts 'Database does not exist - aborting.'
      exit 1
    else
      if File.exist?(seeds_location = context[:config][:seeds_location])
        ::DB = context[:db]
        load seeds_location
      end
    end
  end
end

