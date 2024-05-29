class Biomarker < ApplicationRecord
  belongs_to :biomarker_subcategory

  has_many :lab_results
  has_many :lab_test_biomarkers, dependent: :destroy
  has_many :lab_tests, through: :lab_test_biomarkers

  def biomarker_category
    biomarker_subcategory.biomarker_category
  end

  def self.find_by_biomarker_name(name)
    # Get Biomarker from name or alternative names, case insensitive
    biomarker = Biomarker.find_by("name ILIKE ?", "#{name}")
    if biomarker.blank?
      biomarker = Biomarker.where("EXISTS (
        SELECT 1
        FROM unnest(alternative_names) AS unnested_name
        WHERE LOWER(unnested_name) = LOWER(?)
      )", name).first
    end
    if biomarker.present?
      return biomarker
    else
      Rails.logger.info "Biomarker not found: #{name}"
      AdminMailer.with(name: name, context: {
        file_location: "biomarker.rb",
        function_name: "find_by_biomarker_name",
      }).biomarker_not_found.deliver_later
      return nil
    end
  end
end
