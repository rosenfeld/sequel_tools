# frozen-string-literal: true

require 'fileutils'

RSpec.describe 'A complex workflow around 2 migrations being managed in different orders' do
  before do
    FileUtils.rm_f schema_location
    drop_test_database_if_exists
  end

  before(:all) do
    FileUtils.rm_f Dir["#{migrations_path}/*.rb"]
    File.write "#{migrations_path}/20171111111111_first.rb", <<~FIRST_MIGRATION
      Sequel.migration { change { create_table(:first){ primary_key :id } } }
    FIRST_MIGRATION
    File.write "#{migrations_path}/20171111111112_second.rb", <<~SECOND_MIGRATION
      Sequel.migration { change { create_table(:second){ primary_key :id } } }
    SECOND_MIGRATION
  end

  it 'runs migration up, down, redo, check version and status, migrate and rollback' do
    expect(File.exist?(schema_location)).to be false
    expect(rake_runner.run_task('dbtest:create')).to be_successful
    with_dbtest do |db|
      status_result = rake_runner.run_task('dbtest:status')
      expect(status_result).to be_successful
      expect(status_result.stdout).
        to eq "Unapplied migrations:\n  - 20171111111111_first.rb\n  - 20171111111112_second.rb\n\n"

      expect(db.tables).to_not include :second
      expect(rake_runner.run_task('dbtest:up[20171111111112_second.rb]')).to be_successful

      expect(rake_runner.run_task('dbtest:status').stdout).
        to eq "Unapplied migrations:\n  - 20171111111111_first.rb\n\n"

      version_result = rake_runner.run_task('dbtest:version')
      expect(version_result).to be_successful
      expect(version_result.stdout).to eq "20171111111112_second.rb\n"

      second_attempt = rake_runner.run_task('dbtest:up[20171111111112_second]')
      expect(second_attempt).to_not be_successful
      expect(second_attempt.stdout).to eq('Expected a single unapplied migration for ' +
        "20171111111112_second.rb but found 0. Aborting.\n")
      schema = File.read(schema_location)
      expect(schema).to match /20171111111112_second/
      expect(schema).to_not match /20171111111111_first/
      expect(db.tables).to include :second

      expect(db[:second].count).to be 0
      db[:second].insert id: 1
      expect(db[:second].count).to be 1
      expect(rake_runner.run_task('dbtest:redo[20171111111112_second.rb]')).to be_successful
      expect(schema).to match /20171111111112_second/
      expect(schema).to_not match /20171111111111_first/
      expect(db.tables).to include :second
      expect(db[:second].count).to be 0

      expect(rake_runner.run_task('dbtest:down[20171111111112_second]')).to be_successful
      expect(db.tables).to_not include :second
      schema = File.read(schema_location)
      expect(schema).to_not match /20171111111112_second/
      expect(schema).to_not match /20171111111111_first/

      second_attempt = rake_runner.run_task('dbtest:down[20171111111112_second.rb]')
      expect(second_attempt).to_not be_successful
      expect(second_attempt.stdout).to eq('Expected a single unapplied migration for ' +
        "20171111111112_second.rb but found 0. Aborting.\n")

      expect(rake_runner.run_task('dbtest:migrate')).to be_successful
      expect(db.tables).to include :first, :second
      schema = File.read(schema_location)
      expect(schema).to match /20171111111112_second/
      expect(schema).to match /20171111111111_first/

      expect(rake_runner.run_task('dbtest:status').stdout).
        to eq "No pending migrations in the database\n"

      second_migration_path = "#{migrations_path}/20171111111112_second.rb"
      File.rename second_migration_path, "#{second_migration_path}.ignored"

      expect(rake_runner.run_task('dbtest:status').stdout).
        to eq "The following migrations were applied to the database but can't be found in " +
              "#{migrations_path}:\n  - 20171111111112_second.rb\n\n"

      expect(rake_runner.run_task('dbtest:rollback')).to be_successful
      expect(db.tables).to_not include :first
      expect(db.tables).to include :second
      schema = File.read(schema_location)
      expect(schema).to_not match /20171111111111_first/
      expect(schema).to match /20171111111112_second/
      expect(rake_runner.run_task('dbtest:version').stdout).to eq "20171111111112_second.rb\n"

      expect(rake_runner.run_task('dbtest:status').stdout).
        to eq "The following migrations were applied to the database but can't be found in " +
              "#{migrations_path}:\n  - 20171111111112_second.rb\n\n" +
              "Unapplied migrations:\n  - 20171111111111_first.rb\n\n"

      File.rename "#{second_migration_path}.ignored", second_migration_path

      expect(rake_runner.run_task('dbtest:status').stdout).
        to eq "Unapplied migrations:\n  - 20171111111111_first.rb\n\n"

      expect(rake_runner.run_task('dbtest:rollback')).to be_successful
      expect(db.tables).to_not include :first
      expect(db.tables).to_not include :second
      schema = File.read(schema_location)
      expect(schema).to_not match /20171111111111_first/
      expect(schema).to_not match /20171111111112_second/
      expect(rake_runner.run_task('dbtest:version').stdout).to eq "No migrations applied\n"

      expect(rake_runner.run_task('dbtest:status').stdout).to eq(
        "Unapplied migrations:\n  - 20171111111111_first.rb\n  - 20171111111112_second.rb\n\n")

      invalid_rollback_attempt = rake_runner.run_task('dbtest:rollback')
      expect(invalid_rollback_attempt).to_not be_successful
      expect(invalid_rollback_attempt.stdout).
        to eq "No existing migrations are applied - cannot rollback\n"
    end
  end
end

