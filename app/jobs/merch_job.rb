class MerchJob < ActiveJob::Base

  def perform(params = {})
    shop = Shop.find_by(shopify_domain: params[:shop_domain])
    tweeter = params[:tweeter]
    tweet_body = params[:tweet_body]

    session = Capybara::Session.new(:selenium)

    # merchify login page
    session.visit "https://www.merchify.com/home"
    session.click_on('Login')
    session.fill_in('shop', with: shop.shopify_domain)
    session.find('input[type="submit"]').click

    # shopify login page
    session.fill_in('login', with: shop.merchify_username)
    session.fill_in('password', with: shop.merchify_password)
    session.click_on('Log in')

    # merchify product create index
    session.has_content?('Create a new product')
    products = session.all('.create_product_link')
    products.sample.click

    # merchify product create step 1
    session.has_content?('Create a new')
    session.fill_in('title', with: "Merch for #{tweeter}")
    session.fill_in('sku', with: UUID.new.generate)
    session.evaluate_script(
      "$('.redactor_editor > p')[0].innerHTML = 'Your tweet forever: #{tweet_body}'"
    )
    session.find('#step1_btn').click

    # merchify product create step 2
    session.has_content?('Upload a file')
    session.attach_file('file', Rails.root.join('test/files/test_image.jpeg'), visible: false)
    session.click_on("Next Step")

    # merchify product create step 3
    session.has_content?("Fill out the mark up price and we'll auto configure your prices.")
    price_div = session.find('.size_price_div')
    session.find('input[maxlength="6"]').set('5')
    session.click_on("Next Step")

    # merchify product create step 4
    session.click_on("Save Changes")

    # save complete
    session.has_content?("Your product has been saved to Shopify.")
    session.click_on("View my product in Shopify")

    byebug

  rescue => e
    byebug
  end

end
