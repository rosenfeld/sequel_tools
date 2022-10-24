# frozen-string-literal: true

require_relative '../actions_manager'

class SequelTools::ActionsManager
  Action.register :shell_postgres, nil do |args, context|
    c = context[:config]
    psql = c[:psql]
    env = {
      'PGDATABASE' => c[:dbname],
      'PGHOST' => c[:dbhost] || 'localhost',
      'PGPORT' => (c[:dbport] || 5432).to_s,
      'PGUSER' => c[:username],
      'PGPASSWORD' => c[:password].to_s,
    }
    exec env, psql
  end
end
