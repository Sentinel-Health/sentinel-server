class AddAddressFieldsToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :address_line_1, :string
    add_column :users, :address_line_2, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :zip_code, :string
    add_column :users, :country, :string
    add_column :users, :phone_number_verified, :boolean, default: false
  end
end
