class GenerateConditionSummaryJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    user.generate_condition_summary
  end
end
