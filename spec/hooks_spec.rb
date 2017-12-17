# frozen-string-literal: true
require 'fileutils'

RSpec.describe 'before hooks' do
  it 'support before_any, before_action, before_any_adapter and before_action_adapter' do
    drop_test_database_if_exists
    expect(rake_runner.run_task('dbtest:create')).to be_successful
    action_result = rake_runner.run_task('-f Rakefile.hooks dbtest:connect_db')
    expect(action_result).to be_successful
    expect(action_result.stdout).to eq [
      'before_any: connect_db',
      'before_connect_db',
      'before_any_postgres',
      'before_connect_db_postgres',
      '',
    ].join("\n")
  end
end
