# SequelTools [![Build Status](https://travis-ci.org/rosenfeld/sequel_tools.svg?branch=master)](https://travis-ci.org/rosenfeld/sequel_tools)

SequelTools brings some tooling around Sequel migrations and database management, providing tasks
to create, drop and migrate the database, plus dumping and restoring from the last migrated schema.
It can also display which migrations are applied and which ones are missing. It's highly
customizable and supports multiple databases or environments. It integrates well with Rake as well.

Currently only PostgreSQL is supported out-of-the-box for some tasks, but it should allow you to
specify the database vendor specific commands to support your vendor of choice without requiring
changes to SequelTools itself. Other vendors can be supported through additional gems or you may
want to submit pull requests for your preferred DB vendor if you prefer so that it would be
supported out-of-the-box by this gem.

The idea behind SequelTools is to create a collection of supported actions, which depend on the
database adapter/vendor. Those supported actions can then be translated to Rake tasks as a possible
interface.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sequel_tools'
gem 'rake'

# For PostgreSQL:
gem 'pg', platform: :mri
gem 'jdbc-postgres', platform: :jruby
```

And then execute:

    bundle

## Usage

Here's a sample Rakefile supporting migrate actions:

```ruby
require 'bundler/setup'
require 'sequel_tools'

base_config = SequelTools.base_config(
  project_root: File.expand_path(__dir__),
  dbadapter: 'postgres',
  dbname: 'mydb',
  username: 'myuser',
  password: 'secret',
  # default log_level is nil, in which mode the executed actions such as
  # starting/finishing a migration in a given direction or creating and
  # dropping the database are not logged to standard output.
  log_level: :info,

  # Default options:
  sql_log_level: :debug,
  dump_schema_on_migrate: false, # it's a good idea to enable it for the reference environment
  pg_dump: 'pg_dump', # command used to run pg_dump
  pg_dump: 'psql', # command used to run psql when calling rake db:shell if adapter is postgres
  migrations_location: 'db/migrations',
  schema_location: 'db/migrations/schema.sql',
  seeds_location: 'db/seeds.rb',
  # for tasks such as creating the database:
  # when nil, defaults to the value of the :dbadapter config.
  # This is the database we should connect to before executing "create database dbname"
  maintenancedb: :default,
)

namespace 'db' do
  SequelTools.inject_rake_tasks base_config.merge(dump_schema_on_migrate: true), self
end

namespace 'dbtest' do
  SequelTools.inject_rake_tasks base_config.merge(dbname: 'mydb_test'), self
end
```

Then you are able to run several tasks (`rake -T` will list all supported):

    rake db:create
    rake db:new_migration[migration_name]
    rake db:migrate
    # setup creates the database, loads the latest schema
    # and import seeds when available
    rake dbtest:setup
    # reset drops (if existing) then recreate the database, run all migrations
    # and import seeds when available
    rake dbtest:reset
    # shell opens a psql section to the database for the PostgreSQL adapter
    rake db:shell
    # irb runs "bundle exec sequel" pointing to the database and stores the connection in "DB"
    rake db:irb
    rake db:rollback
    rake db:status
    # version displays latest applied migration
    rake db:version
    rake db:seed
    rake db:redo[migration_filename]
    rake db:down[migration_filename]
    rake db:up[migration_filename]
    # schema_dump is called automatically after migrate/rollback/up/down/redo
    # if passing { dump_schema_on_migrate: true } to the config
    rake db:schema_dump
    # database must be empty before calling db:schema_load
    rake db:schema_load

You may define your own command to open a shell to your database upon the 'db:shell' task.
PostgreSQL is supported out-of-the-box, but if it wasn't, here's a sample script that would
get the job done:

```bash
#!/bin/bash

# name it like ~/bin/opensql for example and give it execution permission

PGDATABASE=$DBNAME
PGHOST=$DBHOST
PGPORT=$DBPORT
PGUSER=$DBUSERNAME
PGPASSWORD=$DBPASSWORD
psql
```

Then you may pass `shell_command: '~/bin/opensql'` to `SequelTools.base_config`.

Alternatively you can define the `shell_#{dbadapter}` action if you prefer. Take a look at
the implementation for `shell_postgres` to see how to do that. If you want to share that action
with others you may either submit a pull request to this project or create a separate gem to
add support for your database to `sequel_tools`, which wouldn't require waiting for me to
approve your pull requests and you'd be able to maintain it independently.

## Development and running tests

The tests assume the database `sequel_tools_test_pw` exists and can be only accessed using a
username and password. It also assumes a valid user/passwd is `user_tools_user/secret`. The
database `sequel_tools_test` is also required to exist and it should be possible to access it
using the `trust` authentication method, without requiring a password. You may achieve that by
adding these lines to the start of your `pg_hba.conf`:

```
host sequel_tools_test_pw   all 127.0.0.1/32 md5
host sequel_tools_test      all 127.0.0.1/32 trust
```

Then feel free to run the tests:

    bundle exec rspec

The default strategy is a safe one, which uses `Open3.capture3` to actually run
`bundle exec rake ...` whenever we want to test the Rake integration and we do that many times
in the tests. Running `bundle exec` is slow, so it adds a lot to the test suite total execution
time. Alternatively, although less robust, you may run the tests using a fork-rake approach,
which avoids calling `bundle exec` each time we want to run a Rake task. Just define
the `FORK_RAKE` environment variable:

    FORK_RAKE=1 bundle exec rspec

In my environment this would complete the full suite in about half the time.

## Contributing

Bug reports and pull requests are welcome on GitHub at
[https://github.com/rosenfeld/sequel_tools](https://github.com/rosenfeld/sequel_tools).

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
