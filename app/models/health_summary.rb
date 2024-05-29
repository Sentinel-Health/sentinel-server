class HealthSummary < ApplicationRecord
  belongs_to :user, touch: true

  enum category: { 
    immunizations: 'immunizations',
    allergies: 'allergies',
    medications: 'medications',
    conditions: 'conditions',
    procedures: 'procedures',
    lab_results: 'lab_results',
    exercise: 'exercise',
    unknown: 'unknown'
  }
end
