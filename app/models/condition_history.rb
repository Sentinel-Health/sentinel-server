class ConditionHistory < ApplicationRecord
  belongs_to :condition
  belongs_to :clinical_record

  def source
    clinical_record.source_name
  end
end
