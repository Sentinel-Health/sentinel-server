class Analytics
  def self.client
    Faraday.new(
      url: Rails.application.credentials.amplitude[:api_base_url],
      headers: {
        'Content-Type' => 'application/json',
        'Accept' => '*/*',
      }
    )  do |faraday|
      faraday.response :raise_error
    end
  end

  def self.track(event)
    response = client.post('/2/httpapi', {
      api_key: Rails.application.credentials.amplitude[:api_key],
      events: [event]
    }.to_json)
    JSON.parse(response.body)
  end
end