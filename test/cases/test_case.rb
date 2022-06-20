module ActiveRecord
  class TestCase < ActiveSupport::TestCase #:nodoc:
    self.use_transactional_tests = false
  end
end
