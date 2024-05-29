class UpdateMessagesToSupportTools < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :tool_call_id, :string
    add_column :messages, :tool_calls, :json
  end
end
