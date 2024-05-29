class InternalApi::V1::DevicesController < InternalApi::V1::BaseController
  def create
    device = Device.find_or_initialize_by(user_id: @current_user.id, token: params[:token], device_type: params[:device_type])
    device.save!
    render json: { success: true }
  end
end