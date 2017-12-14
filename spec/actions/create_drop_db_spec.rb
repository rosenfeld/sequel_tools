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
end
