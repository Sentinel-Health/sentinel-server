class InternalApi::V1::HealthProfileController < InternalApi::V1::BaseController
  def show
    @profile = @current_user.health_profile
    render json: HealthProfileJson.new(@profile).call 
  end

  def update
    @profile = HealthProfile.find_or_initialize_by(user_id: @current_user.id)
    @profile.legal_first_name = params[:legal_first_name] unless params[:legal_first_name].blank?
    @profile.legal_last_name = params[:legal_last_name] unless params[:legal_last_name].blank?
    if params[:wheelchair_use].blank?
      @profile.wheelchair_use = nil
    else 
      @profile.wheelchair_use = params[:wheelchair_use] 
    end
    if params[:skin_type].blank?
      @profile.skin_type = nil
    else
      @profile.skin_type = params[:skin_type] unless params[:skin_type].blank?
    end
    if params[:sex].blank?
      @profile.sex = nil
    else
      @profile.sex = params[:sex] unless params[:sex].blank?
    end
    if params[:blood_type].blank?
      @profile.blood_type = nil
    else
      @profile.blood_type = params[:blood_type]
    end
    if params[:dob].blank?
      @profile.dob = nil
    else
      dob = Date.parse(params[:dob])
      if dob.to_date > 18.years.ago
        raise InternalApi::BadRequest.new(I18n.t("health_profile.errors.underage"))
      end

      @profile.dob = params[:dob]
    end
    @profile.save!

    render json: HealthProfileJson.new(@profile).call
  end

  private

  def health_profile_params
    params.permit(
      :dob,
      :legal_first_name,
      :legal_last_name,
      :wheelchair_use,
      :sex,
      :blood_type,
      :skin_type
    )
  end
end