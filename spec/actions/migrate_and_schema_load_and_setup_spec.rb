# frozen-string-literal: true

require 'fileutils'

RSpec.describe 'migrate and schema_load and setup actions', order: :defined do
  before(:all) do
    FileUtils.rm_f schema_location
    FileUtils.rm_f Dir["#{migrations_path}/*.rb"]
  end

  before{ drop_test_database_if_exists }

  it 'migrates and dump schema when configured to' do
    expect(File.exist?(schema_location)).to be false
    expect(rake_runner.run_task('dbtest:create dbtest:new_migration[sample] dbtest:migrate')).
      to be_successful
    expect(File.exist?(schema_location)).to be true
    expect(File.read schema_location).to match /INSERT INTO (public\.)?schema_migrations VALUES \('\d{14}_sample\.rb'\);/
  end

  it 'loads from dump to a new database' do
    expect(rake_runner.run_task('dbtest:create')).to be_successful
    with_dbtest do |db|
      expect(db.tables).to_not include :schema_migrations
      expect(rake_runner.run_task('dbtest:schema_load')).to be_successful
      expect(db.tables).to include :schema_migrations
      expect(db[:schema_migrations].count).to be 1
      expect(db[:schema_migrations].get :filename).to match /\d{14}_sample.rb/
    end
  end

  # does essentially the same as the previous example, plus load seeds if they exist
  it 'setup a new database from last schema dump and seeds' do
    File.write seeds_location, <<~SEEDS_END
      DB << 'create table seed(name text)'
    SEEDS_END
    expect(rake_runner.run_task('dbtest:setup')).to be_successful
    with_dbtest do |db|
      expect(db[:schema_migrations].select_map(:filename).join(';')).to match /\d{14}_sample.rb/
      expect(db.tables).to include :seed
    end
  end

  it 'ignores the seeds part if the seeds file does not exist' do
    File.delete seeds_location
    expect(rake_runner.run_task('dbtest:setup')).to be_successful
    with_dbtest do |db|
      expect(db[:schema_migrations].select_map(:filename).join(';')).to match /\d{14}_sample.rb/
      expect(db.tables).to_not include :seed
    end
  end
end

