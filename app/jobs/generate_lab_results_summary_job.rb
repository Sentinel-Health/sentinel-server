class GenerateLabResultsSummaryJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    user.generate_lab_results_summary
  end
end
