class HealthCategorySample < ApplicationRecord
  belongs_to :user

  scope :over_range, ->(start_date, end_date) { where('start_date >= ? AND end_date <= ?', start_date.beginning_of_day, end_date.end_of_day) }

  def self.fetch_by_type_and_date(sample_type, start_date: nil, end_date: nil)
    query = where(sample_type: sample_type).order(end_date: :desc)
    query = query.where('start_date >= ?', start_date.to_date.beginning_of_day) if start_date
    query = query.where('end_date <= ?', end_date.to_date.end_of_day) if end_date
    query
  end

  def self.remove_overlaps(health_category_samples)
    non_overlapping_samples = []

    health_category_samples.order(end_date: :desc).each do |sample|
      if non_overlapping_samples.empty? || (sample.end_date <= non_overlapping_samples.last.start_date)
        non_overlapping_samples << sample
      end
    end

    non_overlapping_samples
  end
end
