# frozen-string-literal: true

RSpec.describe 'shell action' do
  it 'opens a sql console to the database' do
    expected = /---\s+sequel_tools_test\s/
    expect{
      rake_exec_runner.wait_output 'db:shell', 'select current_database();', expected
    }.to_not raise_exception
  end

  it 'allows a custom command to be provided, which will get the config through ENV' do
    action_result = rake_runner.run_task '-f Rakefile.custom-shell db:shell'
    expect(action_result).to be_successful
    expect(action_result.stdout).to eq "localhost-5432-sequel_tools_user-secret-sequel_tools_test\n"
  end
end

