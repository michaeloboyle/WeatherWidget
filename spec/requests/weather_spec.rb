# spec/requests/weather_spec.rb
require 'rails_helper'

RSpec.describe 'Weathers', type: :request do
  describe 'GET /weather' do
    let(:address) { '1600 Pennsylvania Avenue, DC' }
    let(:geocoded_location) { { latitude: 38.8977, longitude: -77.0365, postal_code: '20500' } }
    let(:forecast) { { temperature: 70.0, high: 75.0, low: 65.0 } }

    before do
      allow(GeocodeService).to receive(:geocode).with(address).and_return(geocoded_location)
      allow(WeatherService).to receive(:get_weather).with(geocoded_location[:latitude], geocoded_location[:longitude]).and_return(forecast)
    end

    it 'returns http success' do
      get weather_path, params: { address: address }
      expect(response).to have_http_status(:success)
    end
  end
end