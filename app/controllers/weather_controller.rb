# app/controllers/weather_controller.rb
class WeatherController < ApplicationController
  def show
    if params[:address].present?
      address = params[:address]
      zip_code = geocode_address(address)

      if zip_code
        cached_forecast = Rails.cache.read(zip_code)

        if cached_forecast
          @forecast = cached_forecast
          @from_cache = true
        else
          @forecast = fetch_forecast_from_api(zip_code)
          Rails.cache.write(zip_code, @forecast, expires_in: 30.minutes)
          @from_cache = false
        end
      else
        render status: :unprocessable_entity, json: { error: 'Unable to geocode address' }
      end
    else
      render template: 'weather/enter_address'
    end
  end

  private

  def geocode_address(address)
    api_key = ENV['GEOCODING_API_KEY']
    response = HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json?address=#{address}&key=#{api_key}")

    Rails.logger.debug("Geocoding API request URL: https://maps.googleapis.com/maps/api/geocode/json?address=#{address}&key=#{api_key}")
    Rails.logger.debug("Geocoding API response code: #{response.code}")
    Rails.logger.debug("Geocoding API response body: #{response.body}")

    if response.success?
      results = JSON.parse(response.body)["results"]
      if results.any?
        location = results.first["geometry"]["location"]
        "#{location['lat']},#{location['lng']}"
      else
        Rails.logger.debug("Geocoding API returned no results")
        nil
      end
    else
      Rails.logger.debug("Geocoding API request failed")
      nil
    end
  end

  def fetch_forecast_from_api(location)
    api_key = ENV['WEATHER_API_KEY']
    response = HTTParty.get("http://api.openweathermap.org/data/2.5/weather?lat=#{location.split(',').first}&lon=#{location.split(',').last}&appid=#{api_key}&units=imperial")
    if response.success?
      {
        temperature: response['main']['temp'],
        high: response['main']['temp_max'],
        low: response['main']['temp_min']
      }
    else
      { error: "Unable to fetch weather data" }
    end
  end
end