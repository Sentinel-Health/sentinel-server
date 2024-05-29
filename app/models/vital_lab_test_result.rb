class VitalLabTestResult < ApplicationRecord
  belongs_to :user

  serialize :results_data, coder: JSON
  encrypts :results_data

  validates :vital_order_id, presence: true
end
