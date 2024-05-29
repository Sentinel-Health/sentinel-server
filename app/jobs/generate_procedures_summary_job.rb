class GenerateProceduresSummaryJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    user.generate_procedures_summary
  end
end
