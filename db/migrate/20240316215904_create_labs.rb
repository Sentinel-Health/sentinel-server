class CreateLabs < ActiveRecord::Migration[7.1]
  def change
    create_table :labs, id: :uuid do |t|
      t.string :name
      t.string :address_line_1
      t.string :address_line_2
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :country
      t.string :phone_number
      t.string :support_email
      t.string :website
      t.string :appointment_url
      t.string :collection_methods, array: true, default: []
      t.string :sample_types, array: true, default: []
      t.integer :vital_lab_id
      t.string :vital_lab_slug

      t.timestamps
    end
  end
end
