class ChangeAuthTimeToInteger < ActiveRecord::Migration[7.1]
  def up
    change_column :sessions, :auth_time, 'integer USING CAST(auth_time AS integer)'
  end

  def down
    change_column :sessions, :auth_time, :string
  end
end
