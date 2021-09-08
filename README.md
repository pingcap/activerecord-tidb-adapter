# ActiveRecord TiDB Adapter

[![Gem Version](https://badge.fury.io/rb/activerecord-tidb-adapter.svg)](https://badge.fury.io/rb/activerecord-tidb-adapter)
[![activerecord-tidb-adapter 7.0](https://github.com/pingcap/activerecord-tidb-adapter/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/pingcap/activerecord-tidb-adapter/actions/workflows/ci.yml)

TiDB adapter for ActiveRecord 5.2, 6.1 and 7.0
This is a lightweight extension of the mysql2 adapter that establishes compatibility with [TiDB](https://github.com/pingcap/tidb).


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-tidb-adapter', '~> 6.1.0'
```

If you're using Rails 5.2, use the 5.2.x versions of this gem.

If you're using Rails 6.1, use the 6.1.x versions of this gem.

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install activerecord-tidb-adapter

## Usage

config/database.yml

```yml
default: &default
  adapter: tidb
  encoding: utf8mb4
  collation: utf8mb4_general_ci
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  host: 127.0.0.1
  port: 4000
  variables:
    tidb_enable_noop_functions: ON
  username: root
  password:

development:
  <<: *default
  database: activerecord_tidb_adapter_demo_development

```

* demo repo with rails 6.1.4: https://github.com/hooopo/activerecord-tidb-adapter-demo

## TiDB features

**[Sequence](https://docs.pingcap.com/tidb/stable/sql-statement-create-sequence)**

Sequence as primary key

```ruby
class TestSeq < ActiveRecord::Migration[6.1]
  def up
    # more options: increment, min_value, cycle, cache
    create_sequence :orders_seq, start: 1024
    create_table :orders, id: false do |t|
      t.primary_key :id, default: -> { "nextval(orders_seq)" }
      t.string :name
    end
  end

  def down
    drop_table :orders
    drop_sequence :orders_seq
  end
end
```

This gem also adds a few helpers to interact with `SEQUENCE`

```ruby
# Advance sequence and return new value
ActiveRecord::Base.nextval("numbers")

# Return value most recently obtained with nextval for specified sequence.
ActiveRecord::Base.lastval("numbers")

# Set sequence's current value
ActiveRecord::Base.setval("numbers", 1234)
```

**[CTE](https://docs.pingcap.com/tidb/dev/sql-statement-with#with)**

```bash
$ bundle add activerecord-cte

```

```ruby
require 'activerecord/cte'

Post
  .with(posts_with_tags: "SELECT * FROM posts WHERE tags_count > 0")
  .from("posts_with_tags AS posts")
# WITH posts_with_tags AS (
#   SELECT * FROM posts WHERE (tags_count > 0)
# )
# SELECT * FROM posts_with_tags AS posts

Post
  .with(posts_with_tags: "SELECT * FROM posts WHERE tags_count > 0")
  .from("posts_with_tags AS posts")
  .count

# WITH posts_with_tags AS (
#   SELECT * FROM posts WHERE (tags_count > 0)
# )
# SELECT COUNT(*) FROM posts_with_tags AS posts

Post
  .with(posts_with_tags: Post.where("tags_count > 0"))
  .from("posts_with_tags AS posts")
  .count

```


## Setting up local TiDB server

Install [tiup](https://github.com/pingcap/tiup)

```shell
$ curl --proto '=https' --tlsv1.2 -sSf https://tiup-mirrors.pingcap.com/install.sh | sh
```
Starting TiDB playground

```shell
$ tiup playground  nightly
```

## Tutorials

* [Build a Rails App with TiDB and the ActiveRecord TiDB Adapter](https://gist.github.com/hooopo/83db933ab07a054f70e23da0ff945747)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Testing

install gems

```
bundle install
```

start tidb server

```
tiup playground  nightly
```

create database for testing

```
MYSQL_USER=root MYSQL_HOST=127.0.0.1 MYSQL_PORT=4000 tidb=1 ARCONN=tidb bundle exec rake db:tidb:rebuild

```

run tidb adapter tests and activerecord buildin tests

```
MYSQL_USER=root MYSQL_HOST=127.0.0.1 MYSQL_PORT=4000 tidb=1 ARCONN=tidb bundle exec rake test:tidb

```

run **ONLY** tidb adapter tests using `ONLY_TEST_TIDB` env:

```
ONLY_TEST_TIDB=1 MYSQL_USER=root MYSQL_HOST=127.0.0.1 MYSQL_PORT=4000 tidb=1 ARCONN=tidb bundle exec rake test:tidb
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pingcap/activerecord-tidb-adapter.

## License

Apache 2.0
