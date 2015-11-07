class AddDefaultToSinceIdOnTweetData < ActiveRecord::Migration
  def change
    change_column :tweet_data, :since_id, :integer, default: 1, limit: 20
  end
end
