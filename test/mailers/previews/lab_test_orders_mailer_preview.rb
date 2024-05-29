# Preview all emails at http://localhost:3000/rails/mailers/lab_test_orders_mailer
class LabTestOrdersMailerPreview < ActionMailer::Preview
  def lab_form_ready
    lab_test_order_id = LabTestOrder.where(detailed_status: "requisition_created").last.id
    LabTestOrdersMailer.with(lab_test_order_id: lab_test_order_id).lab_form_ready
  end

  def order_cancelled
    lab_test_order_id = LabTestOrder.where(status: "cancelled").last.id
    LabTestOrdersMailer.with(lab_test_order_id: lab_test_order_id).order_cancelled
  end

  def results_ready
    lab_test_order_id = LabTestOrder.where(status: "completed").last.id
    LabTestOrdersMailer.with(lab_test_order_id: lab_test_order_id).results_ready
  end

  def sample_with_lab
    lab_test_order_id = LabTestOrder.where(status: "sample_with_lab").last.id
    LabTestOrdersMailer.with(lab_test_order_id: lab_test_order_id).sample_with_lab
  end
end
