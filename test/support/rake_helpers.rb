# frozen_string_literal: true

TIDB_TEST_HELPER = 'test/cases/helper_tidb.rb'

def test_files
  env_activerecord_test_files ||
    env_tidb_test_files ||
    only_activerecord_test_files ||
    only_tidb_test_files ||
    all_test_files
end

def env_activerecord_test_files
  return unless ENV['TEST_FILES_AR'] && !ENV['TEST_FILES_AR'].empty?

  @env_ar_test_files ||= ENV['TEST_FILES_AR']
                         .split(',')
                         .map { |file| File.join ARTest::TiDB.root_activerecord, file.strip }
                         .sort
                         .prepend(TIDB_TEST_HELPER)
end

def env_tidb_test_files
  return unless ENV['TEST_FILES'] && !ENV['TEST_FILES'].empty?

  @env_test_files ||= ENV['TEST_FILES'].split(',').map(&:strip)
end

def only_activerecord_test_files
  return unless ENV['ONLY_TEST_AR']

  activerecord_test_files
end

def only_tidb_test_files
  return unless ENV['ONLY_TEST_TIDB']

  tidb_test_files
end

def all_test_files
  activerecord_test_files + tidb_test_files
end

def activerecord_test_files
  Dir
    .glob("#{ARTest::TiDB.root_activerecord}/test/cases/**/*_test.rb")
    .reject { |x| x =~ %r{/adapters/postgresql/} }
    .reject { |x| x =~ %r{/adapters/sqlite3/} }
    .sort
    .prepend(TIDB_TEST_HELPER)
end

def tidb_test_files
  Dir.glob('test/cases/**/*_test.rb')
end
