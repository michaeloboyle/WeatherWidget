# app/controllers/weather_controller.rb
class WeatherController < ApplicationController
  def show
    if params[:address].present?
      @address = params[:address]
      geocoded_location = GeocodeService.geocode(@address)
      if geocoded_location
        @postal_code = geocoded_location[:postal_code]
        cache_key = "#{@address}_#{@postal_code}"
        @forecast = Rails.cache.fetch(cache_key, expires_in: 1.hour, force: !use_cache?) do
          WeatherService.get_weather(geocoded_location[:latitude], geocoded_location[:longitude])
        end
        @from_cache = !Rails.cache.read(cache_key).nil?
      end
    end

    if @forecast.nil?
      render :enter_address
    else
      render :show
    end
  end

  private

  def use_cache?
    params[:use_cache] != 'false'
  end
end