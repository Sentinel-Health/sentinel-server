class CreateUserConsents < ActiveRecord::Migration[7.1]
  def change
    create_table :user_consents, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :consent_type
      t.datetime :consented_at
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
