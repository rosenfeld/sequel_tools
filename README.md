# SequelTools

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
  maintenancedb: 'postgres' # for tasks such as creating the database
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
    rake dbtest:setup

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
