require 'test_helper'

class MerchJobTest < ActiveSupport::TestCase

  def setup
    @shop = shops(:regular_shop)

    @shop.update_attributes(
      merchify_username: 'kevin.hughes@shopify.com',
      merchify_password: 'deceptacon'
    )

    @job = MerchJob.new
  end

  test "run" do
    product = mock()
    ShopifyAPI::Product.expects(:new).returns(product)
    product.expects(:save)

    @job.perform(
      shop_domain: 'merchmytweet.myshopify.com',
      tweeter: 'kevinhughes27',
      tweet_body: 'this is my proudest achievment!'
    )
  end

end
