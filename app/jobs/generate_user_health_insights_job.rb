class GenerateUserHealthInsightsJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    user.generate_health_insights
  end
end
