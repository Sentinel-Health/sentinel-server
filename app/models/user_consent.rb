class UserConsent < ApplicationRecord
  belongs_to :user

  enum consent_type: {
    privacy_policy: 'privacy_policy',
    terms_of_service: 'terms_of_service',
    hipaa_authorization: 'hipaa_authorization',
    telehealth_consent: 'telehealth_consent',
  }
end
