ShopifyApp.configure do |config|
  config.api_key = "2ddc34b467cde2cf83e250c6e02879b2"
  config.secret = "f8174f58f6b3e255aaa4843faa0274a8"
  config.redirect_uri = "http://localhost:3000/auth/shopify/callback"
  config.scope = "write_products"
  config.embedded_app = true
end
