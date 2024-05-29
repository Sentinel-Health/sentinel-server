class HealthProfileJson
  def initialize(health_profile)
    @health_profile = health_profile
  end

  def call(options=nil)
    return to_json(@health_profile, options) unless @health_profile.respond_to?(:each)
    @health_profile.map { |health_profile| to_json(health_profile, options) }
  end

  private

  def to_json(health_profile, options)
    return nil unless health_profile
    Rails.cache.fetch("json/v1.0/#{health_profile.cache_key_with_version}") do
      {
        id: health_profile.id,
        legalFirstName: health_profile.legal_first_name,
        legalLastName: health_profile.legal_last_name,
        dob: health_profile.dob,
        sex: health_profile.sex,
        bloodType: health_profile.blood_type,
        skinType: health_profile.skin_type,
        wheelchairUse: health_profile.wheelchair_use,
      }
    end
  end
end