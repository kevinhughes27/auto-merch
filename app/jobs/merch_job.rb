require 'capybara/poltergeist'
require 'open-uri'

class MerchJob < ActiveJob::Base
  include WaitForAjax
  include TwitterHelper

  MAX_RETRIES_PER_BLOCK = 10

  def perform(params = {})
    reset_retry_counter

    shop = Shop.find_by(shopify_domain: params[:shopify_domain])
    tweeter = params[:tweeter]
    tweet_body = params[:tweet_body]
    tweet_id = params[:tweet_id]

    session = nil
    if Rails.env.development? || Rails.env.test?
      session = Capybara::Session.new(:selenium)
    else
      Capybara.register_driver :poltergeist do |app|
        Capybara::Poltergeist::Driver.new(app, js_errors: false)
      end

      session = Capybara::Session.new(:poltergeist)
      session.driver.headers = { "User-Agent" => "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.1" }
    end

    # merchify login page
    Rails.logger.info "merchify login page"
    begin
      session.visit "https://www.merchify.com/home"
      session.click_on('Login')
      session.fill_in('shop', with: shop.shopify_domain)
      session.find('input[type="submit"]').click
    rescue => e
      sleep_and_increment(e)
      retry
    end

    # shopify login page
    Rails.logger.info "shopify login page"
    begin
      session.fill_in('login', with: shop.merchify_username)
      session.fill_in('password', with: shop.merchify_password)
      session.click_on('Log in')
    rescue => e
      sleep_and_increment(e)
      retry
    end

    # merchify product create index
    Rails.logger.info "merchify product create index"
    reset_retry_counter
    begin
      session.has_content?('Create a new product')
      products = session.all('.create_product_link')
      products.sample.click
    rescue => e
      sleep_and_increment(e)
      retry
    end

    # merchify product create step 1
    Rails.logger.info "merchify product create step 1"
    reset_retry_counter
    begin
      session.has_content?('Create a new')
      session.fill_in('title', with: "Merch for #{tweeter}")
      session.fill_in('sku', with: UUID.new.generate)
      session.evaluate_script(
        "$('.redactor_editor > p')[0].innerHTML = 'Your tweet forever: #{tweet_body}'"
      )
      session.find('#step1_btn').click
    rescue => e
      sleep_and_increment(e)
      retry
    end

    # merchify product create step 2
    Rails.logger.info "merchify product create step 2"
    reset_retry_counter
    begin
      session.has_content?('Upload a file')

      file = File.open("tmp/#{tweet_id}.png", 'wb')
      file << open("http://www.tweetpng.com/#{tweeter}/tweet/#{tweet_id}.png").read
      Image.resize(file.path, file.path, 4200, 4800)
      file_uploads = session.all('input[type="file"]', visible: false)
      file_uploads.each{ |f| f.set(Rails.root.join(file.path)) }
    rescue => e
      sleep_and_increment(e)
      retry
    end

    begin
      session.click_on("Next Step")
    rescue => e
      sleep_and_increment(e)
      retry
    end

    # merchify product create step 3
    Rails.logger.info "merchify product create step 3"
    reset_retry_counter
    begin
      session.has_content?("Fill out the mark up price and we'll auto configure your prices.")
      session.find('input[maxlength="6"]').set('5')
      price2 = session.first('input[maxlength="5"]')
      price2.set('5') if price2
      session.click_on("Next Step")
    rescue => e
      sleep_and_increment(e)
      retry
    end

    # merchify product create step 4
    Rails.logger.info "merchify product create step 4"
    reset_retry_counter
    begin
      begin
        session.click_on("Save Changes")
      rescue => e
        session.click_on("Save Product")
      end
    rescue => e
      sleep_and_increment(e)
      retry
    end

    # save complete
    Rails.logger.info "saving"
    sleep(1)
    wait_for_ajax(session)
    session.click_on("View my product in Shopify")

    # shopify
    Rails.logger.info "shopify"
    # old selenium code
    #shopify_page = session.driver.browser.window_handles.last
    #session.driver.browser.switch_to.window(shopify_page)
    session.switch_to_window(session.windows.last)
    product_id = session.current_url.split('/').last
    product_url = ""

    shop.with_shopify_session do
      product = ShopifyAPI::Product.new({
        id: product_id,
        published_at: Time.now - 1.day
      })
      product.save
      product_url = "#{shop.shopify_domain}/products/#{product.handle}"
    end

    Rails.logger.info "product_url: #{product_url}"
    TwitterHelper.tweet(tweeter, tweet_id, product_url)

  rescue => e
    byebug if Rails.env.development? || Rails.env.test?
    Rails.logger.error ("#{e.class} -- #{e.message}")

    retry_job
  end

  private

  # shhhh nothing to see here
  def sleep_and_increment(e)
    Rails.logger.error ("#{e.class} -- #{e.message}")

    @retry_counter += 1

    if @retry_counter >= MAX_RETRIES_PER_BLOCK
      raise
    end

    sleep(1)
  end

  def reset_retry_counter
    @retry_counter = 0
  end

end
