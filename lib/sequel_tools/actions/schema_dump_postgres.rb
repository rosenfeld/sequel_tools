# frozen-string-literal: true

require_relative '../actions_manager'
require_relative '../pg_helper'

class SequelTools::ActionsManager
  Action.register :schema_dump_postgres, nil do |args, context|
    c = context[:config]
    pg_dump = c[:pg_dump]
    schema_location = c[:schema_location]

    stdout, stderr, success = PgHelper.run_pg_command c, "#{pg_dump} -s"
    return unless success
    content = stdout
    migrations_table = c[:migrations_table]
    if (migrations_table ? content.include?(migrations_table) :
        (content =~ /schema_(migrations|info)/))
      include_tables = migrations_table ? [migrations_table] :
        ['schema_migrations', 'schema_info']
      extra_tables = c[:extra_tables_in_dump]
      include_tables.concat extra_tables if extra_tables
      table_options = include_tables.map{|t| "-t #{t}"}.join(' ')
      stdout, stderr, success =
        PgHelper.run_pg_command c, "#{pg_dump} -a #{table_options} --inserts"
      unless success
        puts 'failed to dump data for schema_migrations and schema_info. Aborting.'
        exit 1
      end
      content = [content, stdout].join "\n\n"
    end
    require 'fileutils'
    FileUtils.mkdir_p File.dirname schema_location
    File.write schema_location, content
  end
end
