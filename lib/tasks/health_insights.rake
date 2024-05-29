namespace :health_insights do
  desc "Create health insights for all users"
  task create_health_insights: :environment do
    Rails.logger.info "Processing health insights..."
    User.all.pluck(:id).each do |user_id|
      Rails.logger.info "Scheduling health insights for #{user_id}..."
      GenerateUserHealthInsightsJob.perform_later(user_id)
      Rails.logger.info "Finished scheduling health insights for #{user_id}"
    end
    Rails.logger.info "Finished processing health insights"
  end
end
