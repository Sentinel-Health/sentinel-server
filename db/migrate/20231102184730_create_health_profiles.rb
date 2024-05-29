class CreateHealthProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :health_profiles, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.text :dob
      t.text :sex
      t.text :blood_type
      t.text :skin_type
      t.text :wheelchair_use

      t.timestamps
    end
  end
end
