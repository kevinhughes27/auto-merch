namespace :scheduled do
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
