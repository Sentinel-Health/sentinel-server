class ChangeUsersEncryptedAttributesToText < ActiveRecord::Migration[7.1]
  def change
    change_column :users, :email, :text
    change_column :users, :phone_number, :text
    change_column :users, :picture, :text
    change_column :users, :full_name, :text
    change_column :users, :first_name, :text
    change_column :users, :last_name, :text
  end
end
