namespace :scheduled do
  desc "Fetch tweets and queue up jobs to process"
  task fetch_and_merch_tweets: :environment do
    $twitter.mentions_timeline(since_id: TweetData.since_id).reverse_each do |tweet|

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

  desc "Retrieve the last tweet_id"
  task fetch_last_tweet_id: :environment do
    puts "Last tweet on twitter: #{$twitter.mentions_timeline.last.id}"
    puts "Last tweet merched: #{TweetData.since_id}"
    puts "Remaining tweets to get merched: #{$twitter.mentions_timeline(since_id: TweetData.since_id).size}"
  end

  desc "Update the last tweet_id"
  task update_last_tweet_id: :environment do
    puts "Updating last persisted tweet_id to: #{ENV['TWEET_ID'].to_i}"
    TweetData.update_since_id(ENV['TWEET_ID'].to_i)
  end
end
