class AddLabTestOrderReferenceToBiomarkerSamples < ActiveRecord::Migration[7.1]
  def change
    add_reference :biomarker_samples, :lab_test_order, type: :uuid, foreign_key: true
  end
end
