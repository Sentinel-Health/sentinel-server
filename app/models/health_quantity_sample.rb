class HealthQuantitySample < ApplicationRecord
  belongs_to :user

  scope :over_range, ->(start_date, end_date) { where('start_date >= ? AND end_date <= ?', start_date.beginning_of_day, end_date.end_of_day) }

  def self.fetch_by_type_and_date(sample_type, start_date: nil, end_date: nil)
    query = where(sample_type: sample_type).order(end_date: :desc)
    query = query.where('start_date >= ?', start_date.to_date.beginning_of_day) if start_date
    query = query.where('end_date <= ?', end_date.to_date.end_of_day) if end_date
    query
  end

  # Interval options: ['day', 'week', 'month', 'quarter', 'year']
  # Aggregation method options: ['sum', 'count', 'average', 'max', 'min']
  def self.aggregate_by_type_and_date(sample_type, interval: 'day', start_date: nil, end_date: nil, aggregation_method: "sum", full_series: true)    
    query = where(sample_type: sample_type)
    query = query.where('start_date >= ?', start_date) if start_date
    query = query.where('end_date <= ?', end_date) if end_date

    case interval
    when 'day'
      query = query.group_by_day(:start_date, reverse: true, series: full_series)
    when 'week'
      query = query.group_by_week(:start_date, reverse: true, series: full_series)
    when 'month'
      query = query.group_by_month(:start_date, reverse: true, series: full_series)
    when 'quarter'
      query = query.group_by_quarter(:start_date, reverse: true, series: full_series)
    when 'year'
      query = query.group_by_year(:start_date, reverse: true, series: full_series)
    else
      raise ArgumentError, "Invalid interval option: #{interval}. Valid options are: ['day', 'week', 'month', 'quarter', 'year']"
    end

    case aggregation_method
    when "sum"
      query = query.sum(:value)
    when "count"
      query = query.count
    when "average"
      query = query.average(:value)
    when "max"
      query = query.maximum(:value)
    when "min"
      query = query.minimum(:value)
    else
      raise ArgumentError, "Invalid aggregation_method option: #{aggregation_method}. Valid options are: [:sum, :count, :average, :max, :min]"
    end

    query
  end
end
