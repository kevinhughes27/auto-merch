class TweetData < ActiveRecord::Base

  def self.since_id
    first.since_id
  end

  def self.search_query
    first.search_query
  end

  def self.update_since_id(since_id)
    first.update_attributes!(since_id: since_id)
  end

end
