# frozen_string_literal: true

require 'cases/helper'

module TiDB
  class ATest < ActiveRecord::TestCase
    self.use_transactional_tests = false

    def test_a
      puts '111111111111'
      assert true
    end
  end
end
