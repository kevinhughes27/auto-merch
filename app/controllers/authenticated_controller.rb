class AuthenticatedController < ApplicationController
  before_action :login_again_if_different_shop
  around_filter :shopify_session
  layout ShopifyApp.configuration.embedded_app? ? 'embedded_app' : 'application'

  def current_shop
    return nil unless session[:shopify]
    @current_shop ||= Shop.find(session[:shopify])
  end
end
