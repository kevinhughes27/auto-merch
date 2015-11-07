namespace :scheduled do
  desc "Fetch tweets and queue up jobs to process"
  task fetch_tweets: :environment do
    $twitter.mentions_timeline(since_id: TweetData.since_id).reverse_each do |tweet|

      MerchJob.perform_later(
        shopify_domain: 'merchmytweet.myshopify.com',
        tweeter: tweet.user.screen_name,
        tweet_body: tweet.text
      )

      puts tweet.id
      puts tweet.user.screen_name
      puts tweet.text

      TweetData.update_since_id(tweet.id)
    end
  end
end
