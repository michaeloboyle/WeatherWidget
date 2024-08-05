# app/services/weather_service.rb

require 'httparty'

class WeatherService
  def self.get_weather(latitude, longitude)
    response = HTTParty.get('https://api.openweathermap.org/data/2.5/weather', {
      query: {
        lat: latitude,
        lon: longitude,
        appid: ENV['WEATHER_API_KEY'],
        units: 'imperial'
      }
    })

    Rails.logger.info "Weather API response: #{response.body}"

    if response.code == 200
      data = response.parsed_response
      {
        temperature: data['main']['temp'],
        high: data['main']['temp_max'],
        low: data['main']['temp_min']
      }
    else
      Rails.logger.error "Weather API request failed with response code: #{response.code}"
      nil
    end
  rescue StandardError => e
    Rails.logger.error "Weather API request failed with error: #{e.message}"
    nil
  end
end