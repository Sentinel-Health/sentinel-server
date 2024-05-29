class CreateLabTestOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :lab_test_orders, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :lab_test, null: false, foreign_key: true, type: :uuid
      t.string :stripe_checkout_session_id
      t.string :vital_order_id

      t.timestamps
    end
  end
end
