class Vital
  def self.client
    Faraday.new(
      url: Rails.application.credentials.vital[:api_base_url],
      headers: {
        'Content-Type' => 'application/json',
        'x-vital-api-key' => Rails.application.credentials.vital[:api_key],
      }
    )  do |faraday|
      faraday.response :raise_error
    end
  end

  def self.pdf_client
    Faraday.new(
      url: Rails.application.credentials.vital[:api_base_url],
      headers: {
        'Content-Type' => 'application/pdf',
        'x-vital-api-key' => Rails.application.credentials.vital[:api_key],
      }
    )  do |faraday|
      faraday.response :raise_error
    end
  end

  def self.create_user(user_id: nil, dob: nil, timezone: nil)
    response = client.post('/v2/user', {
      client_user_id: user_id,
      fallback_birth_date: dob,
      fallback_time_zone: timezone
    }.to_json)
    JSON.parse(response.body)
  end

  def self.get_user(vital_user_id)
    response = client.get("/v2/user/#{vital_user_id}")
    JSON.parse(response.body)
  end

  def self.get_labs
    response = client.get('/v3/lab_tests/labs')
    JSON.parse(response.body)
  end

  def self.get_lab_biomarkers(lab_id)
    response = client.get("/v3/lab_tests/markers?lab_id=#{lab_id}")
    JSON.parse(response.body)
  end

  def self.get_lab_tests
    response = client.get('/v3/lab_tests')
    JSON.parse(response.body)
  end

  def self.get_lab_test_biomarkers(lab_test_id)
    response = client.get("/v3/lab_tests/#{lab_test_id}/markers")
    JSON.parse(response.body)
  end

  def self.get_area_info(zip_code)
    response = client.get("/v3/order/area/info?zip_code=#{zip_code}")
    JSON.parse(response.body)
  end

  def self.create_lab_test(name: nil, description: nil, fasting: false, lab_id: 0, sample_type: "serum", method: "walk_in_test", marker_ids: [])
    response = client.post('/v3/lab_tests', {
      name: name,
      description: description,
      fasting: fasting,
      lab_id: lab_id,
      sample_type: sample_type,
      method: method,
      marker_ids: marker_ids
    }.to_json)
    JSON.parse(response.body)
  end

  def self.create_lab_test_order(
    user_id: nil,
    lab_test_id: nil,
    patient_details: {
      first_name: nil,
      last_name: nil,
      gender: nil,
      phone_number: nil,
      email: nil,
      dob: nil,
    },
    patient_address: {
      first_line: nil,
      second_line: nil,
      city: nil,
      state: nil,
      zip: nil,
      country: nil
    }
  )
    response = client.post('/v3/order', {
      user_id: user_id,
      lab_test_id: lab_test_id,
      patient_details: patient_details,
      patient_address: patient_address
    }.to_json)
    JSON.parse(response.body)
  end

  def self.get_lab_test_order(order_id)
    response = client.get("/v3/order/#{order_id}")
    JSON.parse(response.body)
  end

  def self.get_lab_test_order_results(order_id)
    response = client.get("/v3/order/#{order_id}/result")
    JSON.parse(response.body)
  end

  def self.get_lab_test_order_results_pdf(order_id)
    response = pdf_client.get("/v3/order/#{order_id}/result/pdf")
    response.body
  end
end