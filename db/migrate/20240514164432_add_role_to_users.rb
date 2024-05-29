class AddRoleToUsers < ActiveRecord::Migration[7.1]
  def change
    create_enum :user_role, %w[admin member]
    add_column :users, :role, :user_role, default: "member", null: false
  end
end
