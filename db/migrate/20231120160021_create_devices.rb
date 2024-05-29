class CreateDevices < ActiveRecord::Migration[7.1]
  def change
    create_table :devices, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :token
      t.string :device_type
      t.string :aws_platform_endpoint_arn

      t.timestamps
    end
  end
end
