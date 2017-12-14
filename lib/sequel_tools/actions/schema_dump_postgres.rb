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
    if content =~ /schema_(migrations|info)/
      stdout, stderr, success =
        PgHelper.run_pg_command c, "#{pg_dump} -a -t schema_migrations -t schema_info --inserts"
      unless success
        puts 'failed to dump data for schema_migrations and schema_info. Aborting.'
        exit 1
      end
      # to make it easier to see the git diffs and to reduce conflicts when working in separate
      # branches, we use a separate line for each value in schema_migrations:
      regex = /(?<=INSERT INTO schema_migrations VALUES \()(.*?)(?=\))/i
      migration_data = stdout.sub(regex){ |m| "\n  #{m.split(',').join(",\n  ")}\n" }
      content = [content, migration_data].join "\n\n"
    end
    require 'fileutils'
    FileUtils.mkdir_p File.dirname schema_location
    File.write schema_location, content
  end
end
