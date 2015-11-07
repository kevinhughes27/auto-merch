class TweetData < ActiveRecord::Base

  def self.since_id
    first.since_id
  end

  def self.search_query
    first.search_query
  end

end
