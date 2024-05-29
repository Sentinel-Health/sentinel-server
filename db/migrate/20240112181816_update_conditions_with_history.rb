class UpdateConditionsWithHistory < ActiveRecord::Migration[7.1]
  def change
    remove_reference :conditions, :clinical_record, type: :uuid, null: false, foreign_key: true
    remove_column :conditions, :recorded_on, :datetime
    remove_column :conditions, :recorded_by, :string
  end
end
