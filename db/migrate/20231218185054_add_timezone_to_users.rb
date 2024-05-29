class AddTimezoneToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :timezone, :string, null: false, default: 'America/Los_Angeles'
  end
end
