class HealthQuantitySummary < ApplicationRecord
  belongs_to :user

  scope :over_range, ->(start_date, end_date) { where('start_date >= ? AND end_date <= ?', start_date.beginning_of_day, end_date.end_of_day) }

  def self.fetch_by_type_and_date(data_type, summary_type: "sum", start_date: nil, end_date: nil)
    query = where(data_type: data_type, summary_type: summary_type).order(date: :desc)
    query = query.where('date >= ?', start_date.to_date.beginning_of_day) if start_date
    query = query.where('date <= ?', end_date.to_date.end_of_day) if end_date
    query
  end

  # Interval options: ['day', 'week', 'month', 'quarter', 'year']
  # Aggregation method options: ['sum', 'count', 'average', 'max', 'min']
  # This is a bit temporary since the summary data could also be an aggregation itself
  def self.aggregate_by_type_and_date(data_type, interval: 'day', start_date: nil, end_date: nil, aggregation_method: "sum", full_series: true)    
    query = where(data_type: data_type, summary_type: "sum")
    query = query.where('date >= ?', start_date) if start_date
    query = query.where('date <= ?', end_date) if end_date

    case interval
    when 'day'
      query = query.group_by_day(:date, reverse: true, series: full_series)
    when 'week'
      query = query.group_by_week(:date, reverse: true, series: full_series)
    when 'month'
      query = query.group_by_month(:date, reverse: true, series: full_series)
    when 'quarter'
      query = query.group_by_quarter(:date, reverse: true, series: full_series)
    when 'year'
      query = query.group_by_year(:date, reverse: true, series: full_series)
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
