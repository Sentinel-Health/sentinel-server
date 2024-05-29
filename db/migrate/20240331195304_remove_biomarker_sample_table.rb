class RemoveBiomarkerSampleTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :biomarker_samples
  end
end
