class Lab < ApplicationRecord
  has_many :lab_tests, dependent: :destroy

  validates :name, presence: true
end
