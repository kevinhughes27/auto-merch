class CreateTweetData < ActiveRecord::Migration
  def change
    create_table :tweet_data do |t|
      t.integer :since_id, limit: 20
      t.string :search_query
    end
  end
end
