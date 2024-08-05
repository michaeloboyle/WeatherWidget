# spec/controllers/weather_controller_spec.rb
require 'rails_helper'

RSpec.describe WeatherController, type: :controller do
  let(:address) { '1600 Pennsylvania Avenue NW, Washington, DC' }
  let(:geocoded_location) { { latitude: 38.8977, longitude: -77.0365, postal_code: '20500' } }
  let(:forecast) { { temperature: 70.0, high: 75.0, low: 65.0 } }

  before do
    allow(GeocodeService).to receive(:geocode).with(address).and_return(geocoded_location)
    allow(WeatherService).to receive(:get_weather).and_return(forecast)
  end

  describe 'GET #show' do
    context 'when address is provided' do
      it 'returns a success response' do
        get :show, params: { address: address }
        expect(response).to be_successful
      end

      context 'when caching is enabled' do
        before { Rails.cache.write(address, forecast) }

        it 'caches the forecast data' do
          get :show, params: { address: address }
          expect(Rails.cache.read(address)).to eq(forecast)
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
        before { Rails.cache.clear }

        it 'does not use the cache' do
          get :show, params: { address: address }
          expect(Rails.cache.read(address)).to be_nil
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
        expect(response).to render_template(:enter_address)
      end
    end
  end
end