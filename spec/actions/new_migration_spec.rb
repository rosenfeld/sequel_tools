# frozen-string-literal: true

require 'fileutils'

RSpec.describe 'new_migration action' do
  before{ FileUtils.rm_f Dir["#{migrations_path}/*.rb"] }

  it 'generates a new migration file' do
    expect(Dir["#{migrations_path}/*.rb"]).to be_empty
    expect(rake_runner.run_task('dbtest:new_migration[first_migration]')).to be_successful
    migrations = Dir["#{migrations_path}/*.rb"]
    expect(migrations.size).to eq 1
    expect(File.basename migrations[0]).to match /\A\d+_first_migration\.rb\z/
    content = File.read migrations[0]
    expect(content).to match /# documentation available at/m
    expect(content).to match /\sSequel.migration do/m
  end
end

