class GenerateImmunizationSummaryJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    user.generate_immunization_summary
  end
end
