namespace :health_summaries do
  desc "Create health summaries for all users"
  task create_health_summaries: :environment do
    Rails.logger.info "Processing health summaries..."
    User.all.pluck(:id).each do |user_id|
      Rails.logger.info "Scheduling health summaries for #{user_id}..."
      GenerateUserHealthSummariesJob.perform_later(user_id)
      Rails.logger.info "Finished scheduling health summaries for #{user_id}"
    end
    Rails.logger.info "Finished processing health summaries"
  end
end
