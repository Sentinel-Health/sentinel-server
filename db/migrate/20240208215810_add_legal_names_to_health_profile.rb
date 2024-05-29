class AddLegalNamesToHealthProfile < ActiveRecord::Migration[7.1]
  def change
    add_column :health_profiles, :legal_first_name, :text
    add_column :health_profiles, :legal_last_name, :text
  end
end
