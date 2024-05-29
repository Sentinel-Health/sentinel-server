class InternalApi::V1::LabTestsController < InternalApi::V1::BaseController
  def index
    lab_tests = LabTest.active.order(:name)
    render json: {
      unsupportedStates: LabTest::UNSUPPORTED_STATES,
      tests: lab_tests.map { |lab_test| LabTestJson.new(lab_test).call }
    }
  end

  def show
    lab_test = LabTest.find(params[:id])
    raise InternalApi::NotFound.new("Lab test was not found") unless lab_test
    render json: LabTestJson.new(lab_test).call
  end

  def create_checkout
    # First check that they are eligible to purchase the lab test
    @current_user.reload # Ensure we have the latest user data, just in case it was recently updated
    is_eligible, requirements = @current_user.is_eligible_for_lab_tests?
    unless is_eligible
      return render json: {
        ineligible: true,
        requirements: requirements
      }
    end

    # Add check of user's state for lab tests
    if LabTest::UNSUPPORTED_STATES.include?(@current_user.state)
      raise InternalApi::BadRequest.new(I18n.t("lab_tests.errors.unsupported_state"))
    end

    lab_test = LabTest.find(params[:lab_test_id])
    raise InternalApi::BadRequest.new(I18n.t("lab_tests.errors.missing")) unless lab_test
    stripe_customer_id = @current_user.stripe_customer_id
    if stripe_customer_id.nil?
      @current_user.create_stripe_customer
      stripe_customer_id = @current_user.stripe_customer_id
    end
    product_price = Stripe::Product.retrieve(lab_test.stripe_product_id).default_price

    # Create a unique token for the checkout session
    token = SecureRandom.hex(16)
    success_url = "#{ENV['WEB_APP_BASE_URL']}/checkouts/success?token=#{token}"
    checkout_session_params = {
      customer: stripe_customer_id,
      success_url: success_url,
      allow_promotion_codes: true,
      line_items: [
        {
          price: product_price,
          quantity: 1,
        },
      ],
      phone_number_collection: {
        enabled: @current_user.phone_number.blank? # Only collect phone number if it's not already set, we need this for labs, this shouldn't happen but just in case
      },
      mode: 'payment'
    }
    # In case we don't have their address, we need to collect it for the labs, this shouldn't happen but just in case
    if @current_user.address_line_1.blank? || @current_user.city.blank? || @current_user.state.blank? || @current_user.zip_code.blank?
      checkout_session_params[:billing_address_collection] = 'required'
    end
    checkout_session = Stripe::Checkout::Session.create(checkout_session_params)
    
    render json: {
      url: checkout_session.url,
      metadata: checkout_session.metadata,
      customer: checkout_session.customer,
      clientReferenceId: checkout_session.client_reference_id,
      successUrl: success_url,
      checkoutToken: token
    }
  end

  def confirm_consent
    accepted_telehealth_consent = params[:accepted_telehealth_consent]
    accepted_hipaa_authorization = params[:accepted_hipaa_authorization]

    is_eligible, requirements = @current_user.is_eligible_for_lab_tests?
    if requirements.include?(:hipaa_authorization) && !accepted_hipaa_authorization
      raise InternalApi::BadRequest.new(I18n.t("lab_tests.errors.missing_hipaa_consent"))
    end
    if requirements.include?(:telehealth_consent) && !accepted_telehealth_consent
      raise InternalApi::BadRequest.new(I18n.t("lab_tests.errors.missing_telehealth_consent"))
    end

    if accepted_telehealth_consent
      @current_user.user_consents.create!(
        consent_type: :telehealth_consent,
        consented_at: Time.zone.now,
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )
    end
    if accepted_hipaa_authorization
      @current_user.user_consents.create!(
        consent_type: :hipaa_authorization, 
        consented_at: Time.zone.now,
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )
    end

    render json: { success: true }
  end
end