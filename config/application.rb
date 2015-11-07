require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MerchMyTweet
  class Application < Rails::Application
    config.action_dispatch.default_headers['P3P'] = 'CP="Not used"'
    config.action_dispatch.default_headers.delete('X-Frame-Options')
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    $twitter = config.twitter = Twitter::REST::Client.new do |config|
      config.consumer_key        = "kJY0mpfGUNn0yZyN0uOmJbzlS"
      config.consumer_secret     = "vBYtsTWD3wMJD49paxwMwPHGF61E0jRJhsGhXappqNKVVkua1R"
      config.access_token        = "4133085867-ZlmnB8jQzbjA0BBjVlCAMj15QyPXnQEjl2o1Rni"
      config.access_token_secret = "Xb3620seBIKF6AKzfn59z2Yh9NURGuGeLXd2Ebbes66hK"
    end
  end
end
