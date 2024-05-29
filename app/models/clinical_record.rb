class ClinicalRecord < ApplicationRecord
  belongs_to :user, touch: true

  has_many :lab_results, dependent: :destroy
  has_one :medication, dependent: :destroy
  has_one :condition_history, dependent: :destroy
  has_one :immunization, dependent: :destroy
  has_one :procedure, dependent: :destroy
  has_one :allergy, dependent: :destroy

  serialize :fhir_data, coder: JSON
  encrypts :fhir_data
end
