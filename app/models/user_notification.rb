class UserNotification < ApplicationRecord
  belongs_to :user, touch: true

  enum notification_type: { 
    generic: 'generic',
    new_check_in: 'new_check_in',
    new_message: 'new_message',
    new_lab_results: 'new_lab_results',
    new_biomarkers: 'new_biomarkers',
    updated_health_suggestions: 'updated_health_suggestions',
    completed_data_sync: 'completed_data_sync',
    updated_chat_suggestions: 'updated_chat_suggestions',
    lab_test_order_update: 'lab_test_order_update',
  }

  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }
  scope :user_readable, -> { where.not(notification_type: [UserNotification.notification_types[:updated_health_suggestions], UserNotification.notification_types[:updated_chat_suggestions]]) }

  def mark_as_read!
    self.update!(read: true)
  end

  def mark_as_unread!
    self.update!(read: false)
  end

  def mark_as_read
    self.read = true
    self.save
  end

  def mark_as_unread
    self.read = false
    self.save
  end

  def self.mark_all_as_read!(user_id)
    self.where(user_id: user_id).update_all(read: true)
  end

  def self.mark_all_as_unread!(user_id)
    self.where(user_id: user_id).update_all(read: false)
  end
end
