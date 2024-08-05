require 'rails_helper'

RSpec.describe WeatherController, type: :controller do
  describe 'GET #show' do
    let(:address) { '1600 Amphitheatre Parkway, Mountain View, CA' }
    let(:lat_lng) { '37.4224764,-122.0842499' }
    let(:forecast) { { temperature: 72, high: 75, low: 68 } }

    before do
      allow(controller).to receive(:geocode_address).and_return(lat_lng)
      allow(controller).to receive(:fetch_forecast_from_api).and_return(forecast)
    end

    context 'when address is provided' do
      context 'when caching is enabled' do
        before do
          allow(Rails.cache).to receive(:read).with(lat_lng).and_return(nil)
          allow(Rails.cache).to receive(:write).with(lat_lng, forecast, expires_in: 30.minutes)
        end

        it 'caches the forecast data' do
          get :show, params: { address: address }
          expect(Rails.cache).to have_received(:write).with(lat_lng, forecast, expires_in: 30.minutes)
        end

        it 'returns a success response' do
          get :show, params: { address: address }
          expect(response).to be_successful
        end

        it 'fetches forecast data' do
          get :show, params: { address: address }
          expect(assigns(:forecast)).to eq(forecast)
        end
      end

      context 'when caching is disabled' do
        before do
          allow(Rails.cache).to receive(:read).with(lat_lng).and_return(nil)
        end

        it 'does not use the cache' do
          get :show, params: { address: address }
          expect(Rails.cache).to have_received(:read).with(lat_lng)
        end

        it 'returns a success response' do
          get :show, params: { address: address }
          expect(response).to be_successful
        end

        it 'fetches forecast data' do
          get :show, params: { address: address }
          expect(assigns(:forecast)).to eq(forecast)
        end
      end
    end

    context 'when address is not provided' do
      it 'renders the enter_address template' do
        get :show
        expect(response).to render_template('enter_address')
      end
    end
  end

  describe '#geocode_address' do
    it 'returns latitude and longitude for a given address' do
      response_body = {
        "results" => [
          {
            "geometry" => {
              "location" => {
                "lat" => 37.4224764,
                "lng" => -122.0842499
              }
            }
          }
        ]
      }.to_json

      response_double = double('HTTParty::Response', success?: true, code: 200, body: response_body, parsed_response: JSON.parse(response_body))
      allow(HTTParty).to receive(:get).and_return(response_double)
      expect(controller.send(:geocode_address, '1600 Amphitheatre Parkway, Mountain View, CA')).to eq('37.4224764,-122.0842499')
    end
  end

  describe '#fetch_forecast_from_api' do
    it 'returns forecast data for a given location' do
      response_body = {
        "main" => {
          "temp" => 72,
          "temp_max" => 75,
          "temp_min" => 68
        }
      }.to_json

      response_double = double('HTTParty::Response', success?: true, body: response_body, parsed_response: JSON.parse(response_body))
      allow(response_double).to receive(:[]).with('main').and_return(response_double.parsed_response['main'])
      allow(HTTParty).to receive(:get).and_return(response_double)
      expect(controller.send(:fetch_forecast_from_api, '37.4224764,-122.0842499')).to eq(temperature: 72, high: 75, low: 68)
    end
  end
end