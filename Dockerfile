# Use an official Ruby runtime as a parent image
FROM ruby:3.1

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# Set the working directory
WORKDIR /app

# Copy the Gemfile and Gemfile.lock into the image
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

# Install the gems
RUN bundle config set --local without 'development test'
RUN bundle install

# Copy the rest of the application code into the image
COPY . /app

# Precompile assets
RUN bundle exec rake assets:precompile

# Expose port 3000 to the outside world
EXPOSE 3000

# Set the entrypoint to the Rails server
ENTRYPOINT ["bundle", "exec"]

# Command to run the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]