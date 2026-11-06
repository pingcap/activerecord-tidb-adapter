# frozen_string_literal: true

require 'cases/helper_tidb'
require 'minitest/mock'

module TiDB
  class TlsTest < ActiveRecord::TestCase
    SSL_OPTIONS = {
      ssl_mode: 'verify_identity',
      sslca: '/path/to/ca.pem',
      sslcapath: '/path/to/certs',
      sslcert: '/path/to/client-cert.pem',
      sslkey: '/path/to/client-key.pem',
      sslcipher: 'TLS_AES_256_GCM_SHA384'
    }.freeze

    def test_ssl_options_are_passed_to_mysql2_client
      passed_config = nil
      new_client = lambda do |config|
        passed_config = config
        raise ActiveRecord::ConnectionNotEstablished, 'stop before connecting'
      end

      ActiveRecord::ConnectionAdapters::Mysql2Adapter.stub(:new_client, new_client) do
        assert_raises(ActiveRecord::ConnectionNotEstablished) do
          ActiveRecord::Base.tidb_connection(SSL_OPTIONS.transform_keys(&:to_s).merge('host' => 'example.com'))
        end
      end

      SSL_OPTIONS.each do |key, value|
        assert_equal value, passed_config[key], "#{key} should be passed to the mysql2 client"
      end
    end
  end
end
