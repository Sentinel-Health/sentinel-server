class AddBiomarkerReferencesToLabResults < ActiveRecord::Migration[7.1]
  def change
    add_reference :lab_results, :biomarker, type: :uuid, foreign_key: true
  end
end
