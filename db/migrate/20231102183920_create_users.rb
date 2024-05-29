class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users, id: :uuid  do |t|
      t.string :full_name
      t.string :first_name
      t.string :last_name
      t.string :email, null: false
      t.boolean :email_verified, default: false
      t.string :phone_number
      t.string :picture
      t.boolean :has_completed_onboarding, default: false

      t.timestamps
    end
  end
end
