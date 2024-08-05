# spec/views/weather/enter_address.html.erb_spec.rb
require 'rails_helper'

RSpec.describe "weather/enter_address.html.erb", type: :view do
  it "displays the address form" do
    render template: 'weather/enter_address'

    expect(rendered).to have_selector('form')
    expect(rendered).to have_field('address')
    expect(rendered).to have_button('Get Weather')
  end
end