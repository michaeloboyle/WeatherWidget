# app/services/geocode_service.rb

require 'httparty'

class GeocodeService
  def self.geocode(address)
    response = HTTParty.get('https://maps.googleapis.com/maps/api/geocode/json', {
      query: {
        address: address,
        key: ENV['GEOCODING_API_KEY']
      }
    })

    Rails.logger.info "Geocoding API response: #{response.body}"

    if response.code == 200
      result = response['results'].first

      if result && result['geometry'] && result['geometry']['location']
        postal_code = result['address_components']&.find { |component| component['types'].include?('postal_code') }&.[]('long_name')

        {
          latitude: result['geometry']['location']['lat'],
          longitude: result['geometry']['location']['lng'],
          postal_code: postal_code
        }
      else
        Rails.logger.error "Geocoding API returned unexpected result for address: #{address}"
        nil
      end
    else
      Rails.logger.error "Geocoding API request failed with response code: #{response.code}"
      nil
    end
  rescue StandardError => e
    Rails.logger.error "Geocoding API request failed with error: #{e.message}"
    nil
  end
end