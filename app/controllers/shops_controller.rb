class ShopsController < AuthenticatedController
  def show
    @shop = current_shop
  end

  def update
    @shop = current_shop

    if @shop.update_attributes(shop_params)
      flash[:notice] = 'Settings Saved'
    else
      flash[:error] = 'Settings Error'
    end

    render :show
  end

  private

  def shop_params
    params.require(:shop).permit(
      :merchify_username,
      :merchify_password
    )
  end
end
