class HealthInsight < ApplicationRecord
  belongs_to :user, touch: true

  enum category: { 
    overall: 'overall',
    unknown: 'unknown'
  }
end
