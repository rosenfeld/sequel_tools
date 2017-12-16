# frozen-string-literal: true

RSpec.describe 'create and drop actions', order: :defined do
  before(:all){ drop_test_database_if_exists }

  it 'creates sequel_tools_test_test successfully when it does not exist upon dbtest:create' do
    expect(rake_runner.run_task('dbtest:connect_db')).to_not be_successful
    expect(rake_runner.run_task('dbtest:create dbtest:connect_db')).to be_successful
  end

  it 'aborts if database already exist upon dbtest:create' do
    # second attempt fails because it already exists, examples are ordered in this context
    expect(rake_runner.run_task('dbtest:create')).to_not be_successful
  end

  it 'drops database if it exists on dbtest:drop' do
    expect(rake_runner.run_task('dbtest:drop')).to be_successful
  end

  it 'ignore drop database request if it does not exist on dbtest:drop' do
    expect(rake_runner.run_task('dbtest:drop')).to_not be_successful
  end

  it 'logs actions in verbose mode' do
    create_result = rake_runner.run_task 'dbtestverbose:create'
    expect(create_result).to be_successful
    expect(create_result.stdout).to eq "[INFO] Created database 'sequel_tools_test_test'\n"
    drop_result = rake_runner.run_task 'dbtestverbose:drop'
    expect(drop_result).to be_successful
    expect(drop_result.stdout).to eq "[INFO] Dropped database 'sequel_tools_test_test'\n"
  end

  it 'does not log actions unless in verbose mode' do
    result = rake_runner.run_task 'dbtest:create dbtest:drop'
    expect(result).to be_successful
    expect(result.stdout).to be_empty
  end
end

