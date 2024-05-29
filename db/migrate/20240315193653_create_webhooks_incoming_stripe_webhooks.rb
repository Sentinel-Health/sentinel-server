class CreateWebhooksIncomingStripeWebhooks < ActiveRecord::Migration[7.1]
  def change
    create_table :webhooks_incoming_stripe_webhooks, id: :uuid do |t|
      t.jsonb :data
      t.datetime :processed_at
      t.datetime :verified_at

      t.timestamps
    end
  end
end
