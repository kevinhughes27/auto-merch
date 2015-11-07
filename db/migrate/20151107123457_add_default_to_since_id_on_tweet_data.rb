class AddDefaultToSinceIdOnTweetData < ActiveRecord::Migration
  def change
    change_column :tweet_data, :since_id, :bigint, default: 1
  end
end
