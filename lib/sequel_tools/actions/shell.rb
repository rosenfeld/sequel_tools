# frozen-string-literal: true

require_relative '../actions_manager'

class SequelTools::ActionsManager
  Action.register :shell, 'Open an interactive shell to the database' do |args, context|
    begin
      Action[:connect_db].run({}, context)
    rescue
      puts 'Database does not exist - aborting.'
      exit 1
    else
      c = context[:config]
      if shell_command = c[:shell_command]
        env = {
          'DBHOST' => c[:dbhost], 'DBPORT' => c[:dbport].to_s, 'DBUSERNAME' => c[:username],
          'DBPASSWORD' => c[:password].to_s, 'DBNAME' => c[:dbname]
        }
        exec env, shell_command
      else
        unless action = Action[:"shell_#{c[:dbadapter]}"]
          puts "Opening an interactive shell is not currently supported for #{c[:dbadapter]}." +
               " Aborting"
          exit 1
        end
        action.run({}, context)
      end
    end
  end
end

