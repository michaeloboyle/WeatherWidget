# app/controllers/weather_controller.rb
class WeatherController < ApplicationController
  def show
    if params[:address].present?
      @address = params[:address]
      geocoded_location = GeocodeService.geocode(@address)
      if geocoded_location
        @postal_code = geocoded_location[:postal_code]
        cache_key = "#{@address}_#{@postal_code}"
        Rails.logger.info "Generated cache key: #{cache_key}"

        cached_data = Rails.cache.read(cache_key)
        if cached_data
          @forecast = cached_data
          @from_cache = true
          Rails.logger.info "Data found in cache for key: #{cache_key} - #{@forecast}"
        else
          @forecast = WeatherService.get_weather(geocoded_location[:latitude], geocoded_location[:longitude])
          Rails.cache.write(cache_key, @forecast, expires_in: 30.minutes)
          @from_cache = false
          Rails.logger.info "Data not found in cache for key: #{cache_key}. Fetching from Weather API."
          Rails.logger.info "Weather API response: #{@forecast}"
          Rails.logger.info "Storing data in cache for key: #{cache_key} - #{@forecast}"
        end
      end
    end

    if @forecast.nil?
      flash[:alert] = "Could not retrieve weather data. Please try again later."
      render :enter_address
    else
      render :show
    end
  end
end