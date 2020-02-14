# frozen_string_literal: true

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `port` that Puma will listen on to receive requests; default
# is 3000.
#
# port        ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
#
# environment ENV.fetch("RAILS_ENV") { "development" }
rails_env = ENV.fetch("RAILS_ENV") { "development" }
environment rails_env

# Specifies the `pidfile` that Puma will use.
# pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked web server processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
# workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
#
# preload_app!

# Allow puma to be restarted by `rails restart` command.
# plugin :tmp_restart

# app_dir = File.expand_path("../..", __FILE__)
app_dir = File.expand_path("..", __dir__)
directory app_dir
shared_dir = "#{app_dir}/shared"

if %w[production staging].member?(rails_env)
  # Logging
  stdout_redirect "#{app_dir}/log/puma.stdout.log",
                  "#{app_dir}/log/puma.stderr.log", true

  # Set master PID and state locations
  pidfile "#{shared_dir}/pids/puma.pid"
  state_path "#{shared_dir}/pids/puma.state"

  # Change to match your CPU core count
  workers ENV.fetch("WEB_CONCURRENCY") { 2 }

  preload_app!

  # Set up socket location
  bind "unix://#{shared_dir}/sockets/puma.sock"

  before_fork do
    ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
  end

  on_worker_boot do
    ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
  end
elsif rails_env == "development"
  # Specifies the `port` that Puma will listen on to receive requests;
  # default is 3000.
  port   ENV.fetch("PORT") { 3000 }
  plugin :tmp_restart
end
