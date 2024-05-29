class BiomarkerSubcategory < ApplicationRecord
  belongs_to :biomarker_category

  has_many :biomarkers
end
