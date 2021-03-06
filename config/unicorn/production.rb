require 'dotenv'
Dotenv.overload

# see more
#   https://github.com/tablexi/capistrano3-unicorn/blob/master/examples/unicorn.rb
app_path = "/home/apps/#{ENV['APP_NAME']}"
working_directory "#{app_path}/current"
pid "#{app_path}/current/tmp/pids/unicorn.pid"
listen "/tmp/unicorn.#{ENV['APP_NAME']}.sock"

# default would be stderr_path
# log rotate config example
#   https://github.com/defunkt/unicorn/blob/master/examples/logrotate.conf
stderr_path "#{app_path}/current/log/unicorn.log"
stdout_path "#{app_path}/current/log/unicorn.log"

worker_processes 1

before_exec do |server|
  Dotenv.overload
  ENV['BUNDLE_GEMFILE'] = "#{app_path}/current/Gemfile"
end

preload_app true

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end
