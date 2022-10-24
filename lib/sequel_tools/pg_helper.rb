# frozen-string-literal: true

class PgHelper
  def self.run_pg_command(config, cmd, connect_database: nil)
    require 'open3'
    require 'tempfile'
    Tempfile.open 'pgpass' do |file|
      c = config
      file.chmod 0600
      host = c[:dbhost] || 'localhost'
      port = c[:dbport] || '5432'
      file.write "#{host}:#{port}:#{c[:dbname]}:#{c[:username]}:#{c[:password]}"
      file.close
      env = {
        'PGDATABASE' => connect_database || c[:dbname],
        'PGHOST' => host,
        'PGPORT' => port.to_s,
        'PGUSER' => c[:username],
        'PGPASSFILE' => file.path
      }
      stdout, stderr, status = Open3.capture3 env, cmd
      puts "#{cmd} failed: #{[stderr, stdout].join "\n\n"}" if status != 0
      [ stdout, stderr, status == 0 ]
    end
  end
end
