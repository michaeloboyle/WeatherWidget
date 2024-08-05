# spec/views/weather/show.html.erb_spec.rb
require 'rails_helper'

RSpec.describe "weather/show.html.erb", type: :view do
  before do
    assign(:forecast, { temperature: "72°F", high: "75°F", low: "68°F" })
    assign(:from_cache, false)
  end

  it "displays the weather information" do
    render template: 'weather/show'

    expect(rendered).to have_content("Weather Information")
    expect(rendered).to have_content("Temperature: 72°F")
    expect(rendered).to have_content("High: 75°F")
    expect(rendered).to have_content("Low: 68°F")
  end
end