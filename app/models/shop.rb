class Shop < ActiveRecord::Base
  include ShopifyApp::Shop
  include ShopifyApp::SessionStorage
  attr_encrypted :merchify_password, key: Rails.application.secrets.secret_key_base, attribute: 'merchify_password_encrypted'
end
