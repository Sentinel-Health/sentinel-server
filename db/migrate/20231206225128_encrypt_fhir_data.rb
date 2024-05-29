class EncryptFhirData < ActiveRecord::Migration[7.1]
  def up
    change_column :clinical_records, :fhir_data, :text
  end

  def down
    change_column :clinical_records, :fhir_data, :json, using: 'fhir_data::JSON'
  end
end
