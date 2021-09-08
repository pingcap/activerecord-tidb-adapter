# frozen_string_literal: true

require 'cases/helper_tidb'
require 'models/tidb_post'
require 'activerecord/cte'
require 'pry'

module TiDB
  class CteTest < ActiveRecord::TestCase
    self.use_transactional_tests = false

    def setup
      TidbPost.create(
          [
           {
             archived: false,
             views_count: 90,
             language: 'en'
           },
           {
             archived: true,
             views_count: 123,
             language: 'en'
           },
           {
            archived: true,
            views_count: 456,
            language: 'de'
          },
          {
            archived: false,
            views_count: 500,
            language: 'de'
          }
        ]
      )
    end

    def tearndown
      TidbPost.delete_all
    end

    def test_with_when_hash_is_passed_as_an_argument
      popular_posts = TidbPost.where("views_count > 100")
      popular_posts_from_cte = TidbPost.with(popular_posts: popular_posts).from("popular_posts AS tidb_posts")
      assert popular_posts.any?
      assert_equal popular_posts.to_a, popular_posts_from_cte
    end
  end
end