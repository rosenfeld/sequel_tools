# frozen-string-literal: true

require_relative 'actions_manager'
require 'sequel'

class MigrationUtils
  def self.apply_migration(context, version, direction)
    ( puts 'migration version is missing - aborting.'; exit 1 ) if version.nil?
    filename = "#{File.basename version, '.rb'}.rb"
    migrator = find_migrator context, direction
    migrator.migration_tuples.delete_if{|(m, fn, dir)| fn != filename }
    unless (size = migrator.migration_tuples.size) == 1
      puts "Expected a single unapplied migration for #{filename} but found #{size}. Aborting."
      exit 1
    end
    migrator.run
  end

  def self.find_migrator(context, direction = :up)
    Sequel.extension :migration unless Sequel.respond_to? :migration
    SequelTools::ActionsManager::Action[:connect_db].run({}, context) unless context[:db]
    options = { allow_missing_migration_files: true }
    options[:target] = 0 if direction == :down
    config = context[:config]
    options[:table] = config[:migrations_table] if config[:migrations_table]
    Sequel::Migrator.migrator_class(config[:migrations_location]).
      new(context[:db], config[:migrations_location], options)
  end

  def self.current_version(context)
    migrator = find_migrator(context)
    migrator.ds.order(Sequel.desc(migrator.column)).get migrator.column
  end

  def self.last_found_migration(context)
    migrations_path = context[:config][:migrations_location]
    migrator = find_migrator(context)
    migrator.ds.order(Sequel.desc(migrator.column)).select_map(migrator.column).find do |fn|
      File.exist?("#{migrations_path}/#{fn}")
    end
  end

  def self.migrations_differences(context)
    config = context[:config]
    migrations_path = config[:migrations_location]
    existing = Dir["#{migrations_path}/*.rb"].map{|fn| File.basename(fn).downcase }.sort
    existing.delete(File.basename(config[:seeds_location])&.downcase)
    migrator = find_migrator context
    migrated = migrator.ds.select_order_map(migrator.column)
    unapplied = existing - migrated
    files_missing = migrated - existing
    [ unapplied, files_missing ]
  end
end
