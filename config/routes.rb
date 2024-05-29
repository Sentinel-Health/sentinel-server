require 'sidekiq/web'

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  if Rails.env.development?
    mount Sidekiq::Web => "/sidekiq"
  end
  
  scope module: :internal_api, defaults: { format: :json } do
    namespace :v1 do
      # Sessions
      post '/sessions/oauth/:provider', to: 'sessions#oauth_login'
      post '/sessions/logout', to: 'sessions#logout'
      post '/sessions/refresh', to: 'sessions#refresh'
      get '/sessions', to: 'sessions#show'

      # Users
      get '/me', to: 'users#show'
      post '/me/update', to: 'users#update'
      get '/users/notifications', to: 'users#show_notifications'
      get '/users/notifications/unread/count', to: 'users#get_unread_notification_count'
      post '/users/notifications/:notification_id/read', to: 'users#mark_notification_as_read'
      post '/users/notifications/settings', to: 'users#update_notification_settings'
      post '/users/data_sync/start', to: 'users#start_data_sync'
      post '/users/data_sync/complete', to: 'users#complete_data_sync'
      post '/users/phone_number/send_verification_code', to: 'users#send_phone_verification_code'
      post '/users/phone_number/verify', to: 'users#verify_phone_number'

      # Health Profile
      get '/health_profile', to: 'health_profile#show'
      post '/health_profile/update', to: 'health_profile#update'

      # Devices
      post '/devices', to: 'devices#create'

      # Health Data Syncs
      post '/apple_health/quantity_samples/sync', to: 'apple_health#sync_quantity_samples'
      post '/apple_health/quantity_samples/remove', to: 'apple_health#remove_quantity_samples'
      post '/apple_health/quantity_summaries/sync', to: 'apple_health#sync_quantity_summaries'
      post '/apple_health/category_samples/sync', to: 'apple_health#sync_category_samples'
      post '/apple_health/category_samples/remove', to: 'apple_health#remove_category_samples'
      post '/apple_health/profile/sync', to: 'apple_health#sync_health_profile'
      post '/apple_health/clinical_records/sync', to: 'apple_health#sync_clinical_records'
      post '/apple_health/clinical_records/remove', to: 'apple_health#remove_clinical_records'
      post '/apple_health/workouts/sync', to: 'apple_health#sync_workout_data'
      post '/apple_health/workouts/remove', to: 'apple_health#remove_workout_data'

      # Health Data
      get '/health_data/fitness_stats', to: 'health_data#fitness_stats'
      get '/health_data/sleep_stats', to: 'health_data#sleep_stats'
      get '/health_data/body_stats', to: 'health_data#body_stats'
      
      # Conversations
      get '/conversations', to: 'conversations#index'
      get '/conversations/latest', to: 'conversations#latest'
      get '/conversations/:conversation_id', to: 'conversations#show'
      post '/conversations', to: 'conversations#create'
      post '/conversations/:conversation_id/messages', to: 'conversations#create_message'

      # Onboarding
      post '/onboarding/conversations', to: 'onboarding#create_conversation'
      post '/onboarding/completed', to: 'onboarding#completed_onboarding'
      post '/onboarding/reset', to: 'onboarding#reset_onboarding'
      get '/onboarding/conversation', to: 'onboarding#get_onboarding_conversation'
      post '/onboarding/consents/confirm', to: 'onboarding#confirm_consent'
      post '/onboarding/health_goals', to: 'onboarding#health_goals'

      # Biomarkers
      get '/biomarkers', to: 'biomarkers#index'
      get '/biomarkers/category/:id', to: 'biomarkers#show_category'

      # Medications
      get '/medications', to: 'medications#index'
      get '/medications/:id', to: 'medications#show'
      match '/medications/:id/related_conversations', to: 'medications#related_conversations', via: [:get, :post]
      post '/medications/:id/archive', to: 'medications#archive'

      # Conditions
      get '/conditions', to: 'conditions#index'
      get '/conditions/:id', to: 'conditions#show'
      match '/conditions/:id/related_conversations', to: 'conditions#related_conversations', via: [:get, :post]
      post '/conditions/:id/archive', to: 'conditions#archive'

      # Allergies
      get '/allergies', to: 'allergies#index'
      get '/allergies/:id', to: 'allergies#show'
      match '/allergies/:id/related_conversations', to: 'allergies#related_conversations', via: [:get, :post]
      post '/allergies/:id/archive', to: 'allergies#archive'

      # Immunizations
      get '/immunizations', to: 'immunizations#index'
      get '/immunizations/:id', to: 'immunizations#show'
      match '/immunizations/:id/related_conversations', to: 'immunizations#related_conversations', via: [:get, :post]
      post '/immunizations/:id/archive', to: 'immunizations#archive'

      # Procedures
      get '/procedures', to: 'procedures#index'
      get '/procedures/:id', to: 'procedures#show'
      match '/procedures/:id/related_conversations', to: 'procedures#related_conversations', via: [:get, :post]
      post '/procedures/:id/archive', to: 'procedures#archive'

      # Health Insights
      get '/health_insights', to: 'health_insights#index'

      # Chat Suggestions
      get '/chat_suggestions', to: 'chat_suggestions#index'
      post '/chat_suggestions/:id/used', to: 'chat_suggestions#suggestion_used'

      # Chat Feedback
      post '/chat/feedback', to: 'chat_feedback#create'

      # Lab Tests
      get '/lab_tests', to: 'lab_tests#index'
      get '/lab_tests/:id', to: 'lab_tests#show'
      post '/lab_tests/create_checkout', to: 'lab_tests#create_checkout'
      post '/lab_tests/consents/confirm', to: 'lab_tests#confirm_consent'

      # Lab Test Orders
      get '/lab_test_orders', to: 'lab_test_orders#index'
      get '/lab_test_orders/:id', to: 'lab_test_orders#show'
      post '/lab_test_orders/:id/results/viewed', to: 'lab_test_orders#results_viewed'
    end
  end

  namespace :webhooks do
    namespace :incoming do
      post '/stripe', to: 'stripe_webhooks#handle_event'
      post '/vital', to: 'vital_webhooks#handle_event'
    end
  end
end
