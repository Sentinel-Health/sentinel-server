class HealthProfile < ApplicationRecord
  belongs_to :user

  encrypts :dob
  encrypts :sex
  encrypts :blood_type
  encrypts :skin_type
  encrypts :wheelchair_use
  encrypts :legal_first_name
  encrypts :legal_last_name

  after_save :update_user_name, if: -> { saved_change_to_legal_first_name? || saved_change_to_legal_last_name? }

  private

  def update_user_name
    user.first_name = legal_first_name unless user.first_name.present?
    user.last_name = legal_last_name
    user.save
  end
end
