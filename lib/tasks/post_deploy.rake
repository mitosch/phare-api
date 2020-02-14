# frozen_string_literal: true

desc "post deploy to production"
task post_deploy: :environment do
  #
  # Run migrations
  #
  if Rake.application.lookup("db:migrate")
    puts "Running migrations if necessary"
    puts "[ rake db:migrate ]"
    Rake::Task["db:migrate"].invoke
  end

  #
  # Clearing Cache
  #
  # puts "Cleaning up tmp"
  # Rake::Task["tmp:clear"].invoke

  #
  # Restart puma
  #
  puts "Restarting puma"
  system "bundle exec pumactl -S shared/pids/puma.state " \
    "-F config/puma.rb restart"
end
