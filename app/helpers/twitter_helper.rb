module TwitterHelper

  @emoji = {
    :smile => "\xF0\x9F\x98\x83",
    :gift => "\xF0\x9F\x8E\x81",
    :moneybag => "\xF0\x9F\x92\xB0",
    :cash => "\xF0\x9F\x92\xB5",
    :tshirt => "\xF0\x9F\x91\x95",
    :mug => "\xF0\x9F\x8D\xBA"
  }

  @tweet_text = {
    :tshirt => "Your personalized #{@emoji[:tshirt]} is waiting for you! #{@emoji[:gift]} #{@emoji[:smile]}",
    :mug => "Show off to your friends with your own #{@emoji[:mug]} glass."
  }

  def tweet(tweeter, product_url)
    $twitter.update("#{tweeter} #{@tweet_text(:mug)} #{product_url}")
  end
end
