class LabTestOrdersMailer < ApplicationMailer

  def lab_form_ready
    @lab_test_order = LabTestOrder.find(params[:lab_test_order_id])
    @lab_test = @lab_test_order.lab_test
    @user = @lab_test_order.user
    if @lab_test_order.requisition_form.present?
      requisition_form = @lab_test_order.requisition_form
      attachments[requisition_form.filename.to_s] = requisition_form.download
    end
    mail(
      to: @user.email,
      subject: "It's time for your lab test"
    )
  end

  def order_cancelled
    @lab_test_order = LabTestOrder.find(params[:lab_test_order_id])
    @lab_test = @lab_test_order.lab_test
    @user = @lab_test_order.user
    mail(
      to: @user.email,
      subject: "Your lab test order was cancelled"
    )
  end

  def results_ready
    @lab_test_order = LabTestOrder.find(params[:lab_test_order_id])
    @lab_test = @lab_test_order.lab_test
    @user = @lab_test_order.user
    @has_attachment = false
    if @lab_test_order.results_pdf.present?
      results_pdf = @lab_test_order.results_pdf
      attachments[results_pdf.filename.to_s] = results_pdf.download
      @has_attachment = true
    end
    mail(
      to: @user.email,
      subject: "Your lab test results are ready!"
    )
  end

  def sample_with_lab
    @lab_test_order = LabTestOrder.find(params[:lab_test_order_id])
    @lab_test = @lab_test_order.lab_test
    @user = @lab_test_order.user
    mail(
      to: @user.email,
      subject: "Your lab test is with the lab"
    )
  end
end
