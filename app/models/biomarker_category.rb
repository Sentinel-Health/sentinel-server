class BiomarkerCategory < ApplicationRecord
  has_many :biomarker_subcategories, dependent: :destroy
  has_many :biomarkers, through: :biomarker_subcategories
end
