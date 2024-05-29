class ChatSuggestion < ApplicationRecord
  belongs_to :user, touch: true
end
