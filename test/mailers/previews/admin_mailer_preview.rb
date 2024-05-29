# Preview all emails at http://localhost:3000/rails/mailers/admin_mailer
class AdminMailerPreview < ActionMailer::Preview
  def critical_error
    error = "There was something that went horribly wrong"
    context = {
      file_location: 'test/mailers/previews/admin_mailer_preview.rb',
      function_name: 'critical_error',
    }
    AdminMailer.with(error: error, context: context).critical_error
  end

  def lab_test_order_issue
    issue = "There was some issue with an order"
    context = {
      user_id: User.first.id,
      lab_test_order_id: LabTestOrder.first.id,
      status: LabTestOrder.first.status
    }
    AdminMailer.with(issue: issue, context: context).lab_test_order_issue
  end

  def biomarker_not_found
    name = "Some biomarker"
    context = {
      lab_test_id: LabTest.first.id,
      file_location: 'test/mailers/previews/admin_mailer_preview.rb',
      function_name: 'biomarker_not_found',
    }
    AdminMailer.with(name: name, context: context).biomarker_not_found
  end
end
