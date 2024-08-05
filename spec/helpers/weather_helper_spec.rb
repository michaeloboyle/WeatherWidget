# spec/helpers/weather_helper_spec.rb
require 'rails_helper'

RSpec.describe WeatherHelper, type: :helper do
  describe "#format_temperature" do
    it "formats the temperature with °F" do
      expect(helper.format_temperature(72)).to eq('72°F')
    end
  end
end