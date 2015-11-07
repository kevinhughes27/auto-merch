require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  handler do |job, time|
    puts "Running #{job}, at #{time}"

    $twitter.mentions_timeline(since_id: TweetData.since_id).reverse_each do |tweet|
      if tweet.user.screen_name != "merchmytweet"
        MerchJob.perform_later(
          shopify_domain: 'merchmytweet.myshopify.com',
          tweeter: tweet.user.screen_name,
          tweet_body: tweet.text,
          tweet_id: tweet.id
        )

        puts tweet.id
        puts tweet.user.screen_name
        puts tweet.text

        TweetData.update_since_id(tweet.id)
      end
    end
  end

  every(1.minute, 'merch_job.job')
end
