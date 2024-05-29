class ChangeSessions < ActiveRecord::Migration[7.1]
  def change
    remove_column :sessions, :auth_provider, :string
    remove_column :sessions, :uid, :string
    remove_column :sessions, :aud, :string
    remove_column :sessions, :auth_time, :integer

    add_column :sessions, :refresh_token, :string
    add_column :sessions, :ip_address, :string
    add_column :sessions, :device, :string
    add_column :sessions, :platform, :string
  end
end
