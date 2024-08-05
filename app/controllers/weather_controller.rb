# app/controllers/weather_controller.rb

class WeatherController < ApplicationController
  def show
    address = params[:address]
    Rails.logger.debug("Address: #{address}")

    if address.present?
      geocode_result = geocode_address(address)
      if geocode_result["postal_code"].present?
        @postal_code = geocode_result["postal_code"]
        cache_key = @postal_code
      else
        @latitude = geocode_result["latitude"]
        @longitude = geocode_result["longitude"]
        cache_key = "#{@latitude},#{@longitude}"
      end

      cached_forecast = Rails.cache.read(cache_key)

      if cached_forecast
        @forecast = cached_forecast
        @from_cache = true
      else
        @forecast = fetch_forecast_from_api(cache_key)
        Rails.cache.write(cache_key, @forecast, expires_in: 30.minutes)
        @from_cache = false
      end

      @address = address
      @zip_code = cache_key

      if @forecast.nil?
        render :enter_address
      else
        render :show
      end
    else
      render :enter_address
    end
  end

  def geocode_address(address)
    api_key = ENV['GEOCODING_API_KEY']
    response = HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json?address=#{address}&key=#{api_key}")
    Rails.logger.debug("Geocoding API response code: #{response.code}")
    Rails.logger.debug("Geocoding API response body: #{response.body}")

    if response.success?
      results = JSON.parse(response.body)["results"]
      if results.any?
        location = results[0]["geometry"]["location"]
        postal_code_component = results[0]["address_components"].find { |comp| comp["types"].include?("postal_code") }
        postal_code = postal_code_component ? postal_code_component["long_name"] : nil
        return {
          "latitude" => location["lat"],
          "longitude" => location["lng"],
          "postal_code" => postal_code
        }
      end
    end
    { "latitude" => nil, "longitude" => nil, "postal_code" => nil }
  end
  def fetch_forecast_from_api(location)
    api_key = ENV['WEATHER_API_KEY']
    lat, lon = location.split(",")
    response = HTTParty.get("http://api.openweathermap.org/data/2.5/weather?lat=#{lat}&lon=#{lon}&appid=#{api_key}&units=imperial")

    if response.success?
      {
        temperature: response['main']['temp'],
        high: response['main']['temp_max'],
        low: response['main']['temp_min']
      }
    else
      nil
    end
    end
end