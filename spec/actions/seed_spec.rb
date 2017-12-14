# frozen-string-literal: true

RSpec.describe 'seed action' do
  before(:all) do
    drop_test_database_if_exists
    rake_runner.run_task 'dbtest:create'
  end

  it 'defines the DB constant and loads seeds.rb' do
    File.write seeds_location, <<~SEEDS_END
      DB << 'create table seed(name text)' unless DB.tables.include?(:seed)
      DB[:seed].import [:name], [['one'], ['two']] if DB[:seed].empty?
    SEEDS_END
    with_dbtest do |db|
      expect(db.tables).to_not include :seed
      expect(rake_runner.run_task('dbtest:seed')).to be_successful
      expect(db.tables).to include :seed
      expect(db[:seed].select_order_map :name).to eq ['one', 'two']
    end
  end
end

