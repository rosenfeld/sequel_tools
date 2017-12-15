# frozen-string-literal: true

require 'fileutils'

RSpec.describe 'log_level setting' do
  before do
    FileUtils.rm_f Dir["#{migrations_path}/*.rb"]
    File.write "#{migrations_path}/20171111111111_first.rb", <<~FIRST_MIGRATION
      Sequel.migration { change { create_table(:first){ primary_key :id } } }
    FIRST_MIGRATION
    File.write "#{migrations_path}/20171111111112_second.rb", <<~SECOND_MIGRATION
      Sequel.migration { change { create_table(:second){ primary_key :id } } }
    SECOND_MIGRATION
  end

  it 'prints Sequel logs when configured to' do
    drop_test_database_if_exists
    expect(rake_runner.run_task('dbtest:create')).to be_successful
    reset_result = rake_runner.run_task('dbtestverbose:reset')
    expect(reset_result).to be_successful
    expect(reset_result.stdout).to match /\[INFO\] Begin applying migration 20171111111111_first.rb, direction: up\n\[INFO\] Finished applying migration 20171111111111_first.rb, direction: up, took 0\.\d+ seconds\n\[INFO\] Begin applying migration 20171111111112_second.rb, direction: up\n\[INFO\] Finished applying migration 20171111111112_second.rb, direction: up, took 0\.\d+ seconds/
  end
end

