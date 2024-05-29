class CreateSessionAuditTrails < ActiveRecord::Migration[7.1]
  def change
    create_table :session_audit_trails, id: :uuid do |t|
      t.references :user, foreign_key: true, type: :uuid
      t.string :event
      t.string :ip_address
      t.string :user_agent
      t.string :device
      t.string :platform
      t.json :metadata, default: {}

      t.timestamps
    end
  end
end
