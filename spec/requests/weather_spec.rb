# spec/requests/weather_spec.rb
require 'rails_helper'

RSpec.describe "Weathers", type: :request do
  describe "GET /weather" do
    it "returns http success" do
      allow_any_instance_of(WeatherController).to receive(:geocode_address).and_return('37.4219999,-122.0840575')
      allow_any_instance_of(WeatherController).to receive(:fetch_forecast_from_api).and_return({ temperature: 72, high: 75, low: 68 })

      get weather_path, params: { address: 'some address' }
      expect(response).to have_http_status(:success)
    end
  end
end