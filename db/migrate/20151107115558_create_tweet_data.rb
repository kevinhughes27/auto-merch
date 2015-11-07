class CreateTweetData < ActiveRecord::Migration
  def change
    create_table :tweet_data do |t|
      t.bigint :since_id
      t.string :search_query
    end
  end
end
