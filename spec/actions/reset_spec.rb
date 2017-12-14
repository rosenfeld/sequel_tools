# frozen-string-literal: true

require 'fileutils'

RSpec.describe 'reset action' do
  before do
    FileUtils.rm_f Dir["#{migrations_path}/*.rb"]
  end

  it 'recreates the database by rerunning all migrations in a newly created db' do
    File.write "#{migrations_path}/20171111111111_sample.rb", <<~MIGRATION_CONTENT
      Sequel.migration do
        change do
          create_table(:table_name) do
            primary_key :id
            String :name, null: false
          end
        end
      end
    MIGRATION_CONTENT
    File.write seeds_location, <<~SEEDS_END
      DB << 'create table seed(name text)'
    SEEDS_END
    rake_runner.run_task('dbtest:drop dbtest:create dbtest:migrate')
    with_dbtest do |db|
      db << 'create table a(id text)'
      expect(db.tables).to include :a, :table_name
      expect(db.tables).to_not include :seed
    end
    rake_runner.run_task('dbtest:reset')
    with_dbtest do |db|
      expect(db.tables).to include :table_name, :seed
      expect(db.tables).to_not include :a
    end
    expect(File.read schema_location).
      to match /INSERT INTO schema_migrations VALUES \(\n  '20171111111111_sample\.rb'\n\);/
  end
end

