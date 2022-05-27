# frozen_string_literal: true

require 'yaml'
require 'erb'
require 'fileutils'
require 'pathname'
require_relative 'paths_tidb'

module ARTest
  class << self
    def config
      @config ||= read_config
    end

    private

    def config_file
      Pathname.new(ENV['ARCONFIG'] || "#{ARTest::TiDB.test_root_tidb}/config.yml")
    end

    def read_config
      FileUtils.cp "#{ARTest::TiDB.test_root_tidb}/config.example.yml", config_file unless config_file.exist?

      erb = ERB.new(config_file.read)
      expand_config(YAML.parse(erb.result(binding)).transform)
    end

    def expand_config(config)
      config['connections'].each do |adapter, connection|
        dbs = [%w[arunit activerecord_unittest], %w[arunit2 activerecord_unittest2],
               %w[arunit_without_prepared_statements activerecord_unittest]]
        dbs.each do |name, dbname|
          connection[name] = { 'database' => connection[name] } unless connection[name].is_a?(Hash)

          connection[name]['database'] ||= dbname
          connection[name]['adapter']  ||= adapter
        end
      end

      config
    end
  end
end
