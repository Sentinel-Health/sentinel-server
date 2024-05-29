class AddVitalUserIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :vital_user_id, :string
  end
end
