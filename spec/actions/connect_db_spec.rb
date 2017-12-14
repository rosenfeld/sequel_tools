# frozen-string-literal: true

RSpec.describe 'connect_db action' do

  before(:all){ drop_test_database_if_exists }

  it 'connects to sequel_tools_test successfully' do
    expect(rake_runner.run_task('db:connect_db')).to be_successful
  end

  it 'connects to sequel_tools_test_pw successfully' do
    expect(rake_runner.run_task('dbpw:connect_db')).to be_successful
  end

  it 'fails to connect to sequel_tools_test_test when it does not exist' do
    expect(rake_runner.run_task('dbtest:connect_db')).to_not be_successful
  end

  it 'connects to sequel_tools_test_test when it exists' do
    db << 'create database sequel_tools_test_test'
    expect(rake_runner.run_task('dbtest:connect_db')).to be_successful
  end
end
