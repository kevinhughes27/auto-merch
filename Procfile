web: bundle exec unicorn -p $PORT -E $RACK_ENV -c config/unicorn.rb
sidekiq: bundle exec sidekiq
scheduler: clockwork lib/clockwork.rb
