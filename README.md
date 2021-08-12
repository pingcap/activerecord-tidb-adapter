# ActiveRecord TiDB Adapter

TiDB adapter for ActiveRecord 5 and 6. This is a lightweight extension of the mysql2 adapter that establishes compatibility with [TiDB](https://github.com/pingcap/tidb).


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-tidb-adapter'
```

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

## Setting up local TiDB server

Install [tiup](https://github.com/pingcap/tiup)

```shell
$ curl --proto '=https' --tlsv1.2 -sSf https://tiup-mirrors.pingcap.com/install.sh | sh
```
Starting TiDB playground

```shell
$ tiup playground  nightly
```

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

run tidb adapter tests

```
MYSQL_USER=root MYSQL_HOST=127.0.0.1 MYSQL_PORT=4000 tidb=1 ARCONN=tidb bundle exec rake test:idb

```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/activerecord-tidb-adapter.

## License

Apache 2.0
