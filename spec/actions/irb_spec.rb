# frozen-string-literal: true

RSpec.describe 'irb action' do
  # TODO: why isn't this test working under JRuby? The rake task seems to work though
  # and the test for the shell action is pretty similar and works with JRuby...
  it 'opens a sql console to the database', skip: (RUBY_PLATFORM == 'java') do
    expected = /"sequel_tools_test"/
    expect{
      rake_exec_runner.wait_output 'db:irb', 'DB["select current_database()"].get', expected
    }.to_not raise_exception
  end
end

