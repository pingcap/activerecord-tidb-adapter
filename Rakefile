# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'pry'

require_relative 'test/support/paths_tidb'
require_relative 'test/support/rake_helpers'
require_relative 'test/support/config'

task test: ['test:tidb']
task default: [:test]

namespace :test do
  Rake::TestTask.new('tidb') do |t|
    t.libs = ARTest::TiDB.test_load_paths
    t.test_files = test_files
    t.warning = !!ENV['WARNING']
    t.verbose = false
  end

  task 'tidb:env' do
    ENV['ARCONN'] = 'tidb'
    ENV['tidb'] = '1'
  end
end

task 'test:tidb' => 'test:tidb:env'

namespace :db do
  namespace :tidb do
    connection_arguments = lambda do |connection_name|
      config = ARTest.config['connections']['tidb'][connection_name]
      ["--user=#{config['username']}", "--password=#{config['password']}", "--port=#{config['port']}",
       ("--host=#{config['host']}" if config['host'])].join(' ')
    end

    desc 'Build the TiDB test databases'
    task :build do
      config = ARTest.config['connections']['tidb']
      `mysql #{connection_arguments['arunit']} -e "create DATABASE #{config['arunit']['database']} DEFAULT CHARACTER SET utf8mb4 COLLATE #{config['arunit']['collation']}"`
      `mysql #{connection_arguments['arunit2']} -e "create DATABASE #{config['arunit2']['database']} DEFAULT CHARACTER SET utf8mb4 COLLATE #{config['arunit2']['collation']}"`
    end

    desc 'Drop the TiDB test databases'
    task :drop do
      config = ARTest.config['connections']['tidb']
      `mysqladmin #{connection_arguments['arunit']} -f drop #{config['arunit']['database']}`
      `mysqladmin #{connection_arguments['arunit2']} -f drop #{config['arunit2']['database']}`
    end

    desc 'Rebuild the TiDB test databases'
    task rebuild: %i[drop build]
  end
end

task build_mysql_databases: 'db:mysql:build'
