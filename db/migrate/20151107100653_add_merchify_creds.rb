class AddMerchifyCreds < ActiveRecord::Migration
  def change
    add_column :shops, :merchify_username, :string
    add_column :shops, :merchify_password_encrypted, :string
  end
end
