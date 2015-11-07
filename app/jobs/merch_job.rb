class MerchJob < ActiveJob::Base
  include WaitForAjax
  include TwitterHelper

  def perform(params = {})
    shop = Shop.find_by(shopify_domain: params[:shop_domain])
    tweeter = params[:tweeter]
    tweet_body = params[:tweet_body]
    tweet_id = params[:tweet_id]

    debug = false

    session = if debug
      Capybara::Session.new(:selenium)
    else
      Capybara::Session.new(:poltergeist)
    end

    # merchify login page
    Rails.logger.info "merchify login page"
    session.visit "https://www.merchify.com/home"
    session.click_on('Login')
    session.fill_in('shop', with: shop.shopify_domain)
    session.find('input[type="submit"]').click

    # shopify login page
    Rails.logger.info "shopify login page"
    session.fill_in('login', with: shop.merchify_username)
    session.fill_in('password', with: shop.merchify_password)
    session.click_on('Log in')

    # merchify product create index
    Rails.logger.info "merchify product create index"
    sleep(1)
    begin
      session.has_content?('Create a new product')
    rescue
      sleep(1)
      retry
    end

    products = session.all('.create_product_link')
    products.sample.click

    # merchify product create step 1
    Rails.logger.info "merchify product create step 1"
    session.has_content?('Create a new')
    session.fill_in('title', with: "Merch for #{tweeter}")
    session.fill_in('sku', with: UUID.new.generate)
    session.evaluate_script(
      "$('.redactor_editor > p')[0].innerHTML = 'Your tweet forever: #{tweet_body}'"
    )
    session.find('#step1_btn').click

    # merchify product create step 2
    Rails.logger.info "merchify product create step 2"
    session.has_content?('Upload a file')
    #session.attach_file('file', Rails.root.join('test/files/test_image.jpeg'), visible: false)
    file_uploads = session.all('input[type="file"]', visible: false)
    file_uploads.each{ |f| f.set(Rails.root.join('test/files/test_image.jpeg')) }
    session.click_on("Next Step")

    # merchify product create step 3
    Rails.logger.info "merchify product create step 3"
    session.has_content?("Fill out the mark up price and we'll auto configure your prices.")
    session.find('input[maxlength="6"]').set('5')
    price2 = session.first('input[maxlength="5"]')
    price2.set('5') if price2
    session.click_on("Next Step")

    # merchify product create step 4
    Rails.logger.info "merchify product create step 4"
    begin
      session.click_on("Save Changes")
    rescue
      session.click_on("Save Product")
    end

    # save complete
    Rails.logger.info "save complete"
    sleep(1)
    wait_for_ajax(session)
    session.click_on("View my product in Shopify")

    # shopify
    Rails.logger.info "shopify"
    shopify_page = session.driver.browser.window_handles.last
    session.driver.browser.switch_to.window(shopify_page)
    product_id = session.current_url.split('/').last

    shop.with_shopify_session do
      ShopifyAPI::Product.new({
        id: product_id,
        published_at: Time.now - 1.day
      }).save
    end

    product_url = session.find('.google__url').text
    Rails.logger.info "product_url: #{product_url}"

    TwitterHelper.tweet(tweeter, tweet_id, product_url)

  rescue => e
    Rails.logger.error ("#{e.class} -- #{e.message}")
  end

end
