class RemoveSearchQueryFromTweetData < ActiveRecord::Migration
  def change
    remove_column :tweet_data, :search_query
  end
end
