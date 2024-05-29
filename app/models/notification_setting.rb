class NotificationSetting < ApplicationRecord
  belongs_to :user, touch: true
end
