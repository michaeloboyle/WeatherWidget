require 'rails_helper'

RSpec.describe WeatherController, type: :controller do
  describe 'GET #show' do
    context 'when address is provided' do
      let(:address) { '1600 Amphitheatre Parkway, Mountain View, CA' }
      let(:geocoded_location) { { 'latitude' => 37.4224764, 'longitude' => -122.0842499, 'postal_code' => '94043' } }
      let(:forecast_data) { { temperature: 72.0, high: 75.0, low: 68.0 } }

      before do
        allow(controller).to receive(:geocode_address).with(address).and_return(geocoded_location)
      end

      it 'returns a success response' do
        get :show, params: { address: address }
        expect(response).to be_successful
        expect(assigns(:address)).to eq(address)
        expect(assigns(:zip_code)).to eq('94043')
      end

      context 'when caching is enabled' do
        before do
          Rails.cache.clear
        end

        it 'caches the forecast data' do
          allow(controller).to receive(:fetch_forecast_from_api).and_return(forecast_data)
          expect(Rails.cache).to receive(:write).with('94043', forecast_data, expires_in: 30.minutes)
          get :show, params: { address: address }
        end

        it 'returns a success response' do
          Rails.cache.write('94043', forecast_data, expires_in: 30.minutes)
          get :show, params: { address: address }
          expect(response).to be_successful
          expect(assigns(:from_cache)).to be(true)
        end

        it 'fetches forecast data' do
          expect(controller).to receive(:fetch_forecast_from_api).and_return(forecast_data)
          get :show, params: { address: address }
          expect(assigns(:forecast)).to eq(forecast_data)
        end
      end

      context 'when caching is disabled' do
        before do
          Rails.cache.clear
        end

        it 'does not use the cache' do
          allow(controller).to receive(:fetch_forecast_from_api).and_return(forecast_data)
          get :show, params: { address: address }
          expect(assigns(:from_cache)).to be(false)
        end

        it 'returns a success response' do
          allow(controller).to receive(:fetch_forecast_from_api).and_return(forecast_data)
          get :show, params: { address: address }
          expect(response).to be_successful
          expect(assigns(:forecast)).to eq(forecast_data)
        end

        it 'fetches forecast data' do
          expect(controller).to receive(:fetch_forecast_from_api).and_return(forecast_data)
          get :show, params: { address: address }
          expect(assigns(:forecast)).to eq(forecast_data)
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

  describe '#geocode_address' do
    it 'returns latitude and longitude for a given address' do
      address = '1600 Amphitheatre Parkway, Mountain View, CA'
      response_double = double('response', success?: true, code: 200, body: {
        results: [
          {
            geometry: {
              location: {
                lat: 37.4224764,
                lng: -122.0842499
              }
            },
            address_components: [
              { long_name: '94043', types: ['postal_code'] }
            ]
          }
        ]
      }.to_json)

      allow(HTTParty).to receive(:get).and_return(response_double)

      geocoded_location = controller.geocode_address(address)

      expect(geocoded_location['latitude']).to eq(37.4224764)
      expect(geocoded_location['longitude']).to eq(-122.0842499)
      expect(geocoded_location['postal_code']).to eq('94043')
    end
  end

  describe '#fetch_forecast_from_api' do
    it 'returns forecast data for a given location' do
      location = '37.4224764,-122.0842499'
      response_double = double('response', success?: true, body: {
        main: {
          temp: 72.0,
          temp_max: 75.0,
          temp_min: 68.0
        }
      }.to_json)

      allow(HTTParty).to receive(:get).and_return(response_double)
      allow(response_double).to receive(:[]).with('main').and_return(JSON.parse(response_double.body)['main'])

      forecast = controller.fetch_forecast_from_api(location)

      expect(forecast[:temperature]).to eq(72.0)
      expect(forecast[:high]).to eq(75.0)
      expect(forecast[:low]).to eq(68.0)
    end
  end
end