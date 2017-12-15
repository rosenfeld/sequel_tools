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
      expect(config[:db_migrations_location]).to eq '/project_root/db/migrations'
      expect(config[:schema_location]).to eq '/project_root/db/migrations/schema.sql'
      expect(config[:seeds_location]).to eq '/project_root/db/seeds.rb'
    end
  end

  context 'Test database and user exist' do
    it 'can connect to sequel_tools_test without using a password' do
      db = Sequel.connect 'postgres://sequel_tools_user@localhost/sequel_tools_test'
      expect(db['select 1'].get).to eq 1
    end

    it 'can connect to sequel_tools_test_pw using a password' do
      db = Sequel.connect 'postgres://sequel_tools_user:secret@localhost/sequel_tools_test_pw'
      expect(db['select 1'].get).to eq 1
    end

    it 'cannot connect to sequel_tools_test_pw without a password' do
      expect{
        Sequel.connect 'postgres://sequel_tools_user@localhost/sequel_tools_test_pw'
      }.to raise_error Sequel::DatabaseConnectionError
    end
  end
end
