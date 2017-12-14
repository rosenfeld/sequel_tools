# frozen-string-literal: true
require 'fileutils'
require 'sequel_tools/all_actions'

RSpec.describe 'stores schema.sql' do
  context 'creates schema.sql on dbtest:schema_dump' do
    before{ FileUtils.rm_f schema_location }

    context 'without support for postgres adapter' do

      it 'fails if it cannot find support for the db adapter' do
        drop_test_database_if_exists
        expect(rake_runner.run_task('dbtest:create')).to be_successful
        action_result = rake_runner.run_task('-f Rakefile.no_pg_schema_dump dbtest:schema_dump')
        expect(action_result).to_not be_successful
        expect(action_result.stdout).
          to eq "Dumping the db schema is not currently supported for postgres. Aborting\n"
        expect(File.exist?(schema_location)).to be false
      end
    end

    it 'succeeds when no migrations have been applied' do
      expect(File.exist?(schema_location)).to be false
      drop_test_database_if_exists
      expect(rake_runner.run_task('dbtest:create')).to be_successful
      expect(rake_runner.run_task('dbtest:schema_dump')).to be_successful
      expect(File.exist?(schema_location)).to be true
    end

    # the test case exercising data from schema_migrations is exercised in the migrate specs
  end
end
