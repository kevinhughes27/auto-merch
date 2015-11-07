require 'capybara/poltergeist'
require 'open-uri'

class MerchJob < ActiveJob::Base
  include WaitForAjax
  include TwitterHelper

  def perform(params = {})
    shop = Shop.find_by(shopify_domain: params[:shopify_domain])
    tweeter = params[:tweeter]
    tweet_body = params[:tweet_body]
    tweet_id = params[:tweet_id]

    debug = false

    session = nil
    if debug
      session = Capybara::Session.new(:selenium)
    else
      session = Capybara::Session.new(:poltergeist)
      session.driver.headers = { "User-Agent" => "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.1" }
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
    begin
      session.has_content?('Create a new product')
      products = session.all('.create_product_link')
      products.sample.click
    rescue
      sleep(1)
      retry
    end

    # merchify product create step 1
    Rails.logger.info "merchify product create step 1"
    begin
      session.has_content?('Create a new')
      session.fill_in('title', with: "Merch for #{tweeter}")
      session.fill_in('sku', with: UUID.new.generate)
      session.evaluate_script(
        "$('.redactor_editor > p')[0].innerHTML = 'Your tweet forever: #{tweet_body}'"
      )
      session.find('#step1_btn').click
    rescue
      sleep(1)
      retry
    end

    # merchify product create step 2
    Rails.logger.info "merchify product create step 2"
    begin
      session.has_content?('Upload a file')

      open('image.png', 'wb') do |file|
        file << open("http://www.tweetpng.com/#{tweeter}/tweet/#{tweet_id}.png").read
        file_uploads = session.all('input[type="file"]', visible: false)
        file_uploads.each{ |f| f.set(file) }
      end
      session.click_on("Next Step")
    rescue
      sleep(1)
      retry
    end

    # merchify product create step 3
    Rails.logger.info "merchify product create step 3"
    begin
      session.has_content?("Fill out the mark up price and we'll auto configure your prices.")
      session.find('input[maxlength="6"]').set('5')
      price2 = session.first('input[maxlength="5"]')
      price2.set('5') if price2
      session.click_on("Next Step")
    rescue
      sleep(1)
      retry
    end

    # merchify product create step 4
    Rails.logger.info "merchify product create step 4"
    begin
      begin
        session.click_on("Save Changes")
      rescue
        session.click_on("Save Product")
      end
    rescue
      sleep(1)
      retry
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
