class DropFullNameOnUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :full_name, :text
  end
end
