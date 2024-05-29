class InternalApi::V1::LabTestOrdersController < InternalApi::V1::BaseController
  def index
    active_or_not_viewed = params[:active_or_not_viewed] == 'true'

    if active_or_not_viewed
      lab_test_orders = @current_user.lab_test_orders.active_or_not_viewed
    else
      lab_test_orders = @current_user.lab_test_orders
    end
    lab_test_orders = lab_test_orders.order(created_at: :desc)
    render json: {
      orders: lab_test_orders.map { |lab_test_order| LabTestOrderJson.new(lab_test_order).call }
    }
  end

  def show
    lab_test_order = @current_user.lab_test_orders.find(params[:id])
    render json: LabTestOrderJson.new(lab_test_order).call
  end

  def results_viewed
    lab_test_order = @current_user.lab_test_orders.find(params[:id])
    lab_test_order.update!(results_have_been_viewed: true)
    render json: LabTestOrderJson.new(lab_test_order).call
  end
end