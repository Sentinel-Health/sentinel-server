class MakeClinicalRecordsExistanceOptionalForLabResultsAndBiomarkerSamples < ActiveRecord::Migration[7.1]
  def change
    change_column_null :biomarker_samples, :clinical_record_id, true
    change_column_null :lab_results, :clinical_record_id, true
  end
end
