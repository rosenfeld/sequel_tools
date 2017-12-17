# frozen-string-literal: true

require 'sequel'
require 'sequel_tools'

RSpec.describe SequelTools do
  it 'has a version number' do
    expect(SequelTools::VERSION).not_to be nil
  end

  context 'Base configuration' do
    it 'raises if a required key is missing' do
      expect{ SequelTools.base_config }.to raise_error SequelTools::MissingConfigError
    end

    it 'returns a basic configuration given the minimum required information' do
      config = SequelTools.base_config project_root: '/project_root', dbadapter: 'postgres',
        dbname: 'mydb', username: 'myuser'
      expect(config[:migrations_location]).to eq '/project_root/db/migrations'
      expect(config[:schema_location]).to eq '/project_root/db/migrations/schema.sql'
      expect(config[:seeds_location]).to eq '/project_root/db/seeds.rb'
    end
  end

  context 'Test database and user exist' do
    def connect(uri)
      uri = (RUBY_PLATFORM == 'java' ? 'jdbc:postgresql://' : 'postgres://') + uri
      Sequel.connect uri
    end

    it 'can connect to sequel_tools_test without using a password' do
      db = connect 'localhost/sequel_tools_test?user=sequel_tools_user'
      expect(db['select 1'].get).to eq 1
    end

    it 'can connect to sequel_tools_test_pw using a password' do
      db = connect 'localhost/sequel_tools_test_pw?user=sequel_tools_user&password=secret'
      expect(db['select 1'].get).to eq 1
    end

    it 'cannot connect to sequel_tools_test_pw without a password' do
      expect{
        SequelTools.suppress_java_output do
          connect 'localhost/sequel_tools_test_pw?user=sequel_tools_user'
        end
      }.to raise_error Sequel::DatabaseConnectionError
    end
  end
end
