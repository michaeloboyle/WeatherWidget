# WeatherWidget

WeatherWidget is a simple Rails application that fetches and displays weather information based on a provided address. It uses the Google Geocoding API to convert addresses to geographic coordinates and the OpenWeatherMap API to fetch weather data.

## Features

- Enter an address to get weather information.
- Displays temperature, high, and low forecast.
- Caching of weather data.

## Getting Started

### Prerequisites

- Docker
- Ruby (for local development without Docker)

### Installation

1. **Clone the repository**

   ```sh
   git clone https://github.com/yourusername/weather_widget.git
   cd weather_widget
   ```

2. **Set up environment variables**

   Create a `.env` file in the project root and add your API keys:

   ```plaintext
   GEOCODING_API_KEY=your_google_geocoding_api_key
   WEATHER_API_KEY=your_openweathermap_api_key
   ```

3. **Build and run the Docker container**

   ```sh
   docker build -t weather_widget .
   docker run -p 3000:3000 --env-file .env weather_widget
   ```

4. **Alternatively, run locally**
   Ensure you have the required Ruby version and dependencies:
   ```sh
   bundle install
   ```
   Run the application:
   ```sh
   rails server
   ```

### Usage
1. Open your web browser and go to `http://localhost:3000`.
2. Enter an address in the provided form and click "Get Weather".
3. The application will display the current temperature, high, and low forecast for the provided address.

### Enabling/Disabling Caching in Development

By default, caching is disabled in the development environment. You can toggle caching by running the following command:

```sh
rails dev:cache
```
This command creates or removes the tmp/caching-dev.txt file, which controls whether caching is enabled.  When caching is enabled, the following settings are applied:  
- config.action_controller.perform_caching is set to true.
- config.action_controller.enable_fragment_cache_logging is set to true.
- config.cache_store is set to :memory_store.
- config.public_file_server.headers is set to Cache-Control: public, max-age=172800.

When caching is disabled, the following settings are applied:
- config.action_controller.perform_caching is set to false.
- config.cache_store is set to :null_store.

### Running Tests
The application uses RSpec for testing. To run the test suite, execute:

```sh
bundle exec rspec
```

### Docker Setup
The application can be run using Docker. The provided Dockerfile sets up the necessary environment.

To build and run the application:

```sh
docker build -t weather_widget .
docker run -p 3000:3000 --env-file .env weather_widget
```

### Routes
- `GET /weather`: Main endpoint to fetch and display weather information based on a provided address.

### Code Structure
- `app/controllers/weather_controller.rb`: Handles the main logic for fetching and displaying weather data.
- `app/views/weather/enter_address.html.erb`: Form for entering an address.
- `app/views/weather/show.html.erb`: Displays the weather information.
- `spec/`: Contains RSpec tests for controllers and views.

## Contributing

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature-name`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin feature/your-feature-name`).
5. Create a new Pull Request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
