class ChangeUsersRoleToStringType < ActiveRecord::Migration[7.1]
  def up
    change_column :users, :role, :string, default: "member", null: false
    drop_enum :user_role, %w[admin member]
  end

  def down
    create_enum :user_role, %w[admin member]
    change_column_default :users, :role, nil
    change_column :users, :role, :user_role, using: 'role::user_role', null: false
    change_column_default :users, :role, "member"
  end
end
