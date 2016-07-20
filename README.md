# QPush
[![Code Climate](https://codeclimate.com/github/nsweeting/qpush/badges/gpa.svg)](https://codeclimate.com/github/nsweeting/qpush)

Fast and simple job queue microservice for Ruby. **Please consider it under development at the moment.**

QPush provides a scalable solution to your background job processing needs. Its Redis-backed, with support for forking and threading - letting it process an enormous amount of jobs in short order.

As a microservice, QPush is meant to be independent in its operation and deployment. This means that unlike other job processors such as Sidekiq, DelayedJob, etc - QPush does not hook into a web framework. Jobs must therefore be self-sufficent in their operation. This can often lead to better application designs - but also means QPush will have a minimal memory footprint.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'qpush'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install job_que

## Usage

Before starting, ensure you have a functioning Redis server available.

#### The Server

In order to process queued jobs, we run the QPush server. This is a separate service beyond your web application (Rails, Sinatra, etc). To start the server simply type the following in your console.

    $ bundle exec qpush-server -c path/to/config.rb

By providing a path to a configuration file, we can setup QPush with plain old ruby. At a minimum, we should provide details on our Redis server and connections. There are more configuration options available - all of which can be viewed here (to come). Remember to 'require' the files that contain your jobs as well!

```ruby
#We must require our jobs from the config file, otherwise QPush will not be able to access them.
require_relative 'jobs/my_jobs'

# QPush server configuration
QPush.configure do |config|
  # Your redis server url and number of connections to provide
  config.redis_url = ENV['REDIS_URL']
  config.redis_pool = 10
end
```

Once the QPush server is running, it will begin processing any queued jobs based on priority.

#### The Client

Before we can add jobs to our server, we must first ensure our client has the same connection to our Redis server. We can setup our configuration in the same manner as above.

```ruby
require 'qpush'

# QPush client configuration
QPush.configure do |config|
  # Your redis server url and number of connections to provide
  config.redis_url = ENV['REDIS_URL']
  config.redis_pool = 10
end
```

With our client setup, we can now queue jobs on our QPush server. All we have to do is:

```ruby
QPush.job(klass: 'Example::Job', args: { example: 'Job' })
```

The job above would be equivalent to running the following command on the server.

```ruby
Example::Job.new(example: 'Job').call
```

At a minimum, we must provide the job with a 'klass'. There are many more options that we can provide to the job though - [all of which can be viewed here](https://github.com/nsweeting/qpush/wiki/Options-for-Jobs).

#### Building Jobs

Jobs are simply plain old ruby objects that contain a 'call' method. If you provide a hash for the 'args' of the job, the job will be initialized with them. Below is an example of a simple mailing job utilizing the 'mail' gem.

```ruby
require 'mail'

class MailJob
  def initialize(options = {})
    @mail = Mail.new(options)
  end

  def call
    @mail.deliver
  end
end
```

From our client, we could then queue a mail job with the following:

```ruby
mail_options = { to: 'person@example.com', from: 'admin@test.com', subject: 'Hello!', body: 'From MailJob' }
QPush.job(klass: 'MailJob', args: mail_options)
```

#### Failed Jobs

Jobs that raise an error will be sent to the retry queue. As a default, they are set to attempt a maximum of 10 retries. Each failed attempt creates a longer delay for subsequent attempts. The job will permanently fail once the max retries has been hit.

#### Cron Jobs

QPush supports cron jobs. All you have to do is include a cron expression with your job. For example, the following would perform our job everyday at 4AM UTC.

```ruby
QPush.job(klass: 'Example::Job', args: { example: 'Job' }, cron: '0 4 * * *')
```

#### Relational Databases

Although QPush is designed to independent in its operation, it still provides access to relational databases via Sequel. You can read more about [how to use Sequel here](https://github.com/jeremyevans/sequel). Suffice to say, its quite easy. We first will need to add the required information to our configuration:

```ruby
# You must remember to require the gem for whatever database you will be using.
require 'pg'

# QPush database configuration
QPush.configure do |config|
  # Redis and additional config omitted
  # ....
  # ....
  # Your database server url and number of connections to provide
  config.database_url = ENV['DATABASE_URL']
  config.database_pool = 10
end
```

We can then access the database from any job. For example, we could retrieve all of our users with the following:

```ruby
  QPush.db[:users].all
```
It is recommended that you read up on Sequel before use.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nsweeting/qpush. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
