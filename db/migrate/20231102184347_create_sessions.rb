class CreateSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :sessions, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :access_token, null: false
      t.string :auth_provider, null: false
      t.string :uid
      t.integer :exp
      t.integer :iat
      t.string :aud
      t.string :auth_time

      t.timestamps
    end
  end
end
