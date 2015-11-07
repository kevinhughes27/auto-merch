class AddTimestampsToTweetData < ActiveRecord::Migration
  def change
    add_timestamps(:tweet_data)
  end
end
