# frozen_string_literal: true

require 'simplecov'
require 'pundit/rspec'
SimpleCov.start 'rails'
require 'capybara/rspec'
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'devise'
require 'rspec/rails'
require 'database_cleaner'
require 'webmock/rspec'
require 'paper_trail/frameworks/rspec'
include Warden::Test::Helpers
Warden.test_mode!
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

# Add additional requires below this line. Rails is not loaded until this point!

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Factory Girl
  config.include FactoryBot::Syntax::Methods

  # Include Devise test helpers
  config.include Devise::Test::IntegrationHelpers, type: :feature
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.extend ControllerMacros, type: :controller
  config.extend ControllerMacros, type: :feature

  config.include Devise::Test::ControllerHelpers, type: :view

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # This is also best set to 'false' when using another tool to manage the test
  # database, such as database_cleaner

  config.use_transactional_fixtures = false

  config.before(:suite) do
    # and disable callbacks
    Searchkick.disable_callbacks

    if config.use_transactional_fixtures?
      raise(<<-MSG)
        Delete line `config.use_transactional_fixtures = true` from rails_helper.rb
        (or set it to false) to prevent uncommitted transactions being used in
        JavaScript-dependent specs.

        During testing, the app-under-test that the browser driver connects to
        uses a different database connection to the database connection used by
        the spec. The app's database connection would not be able to access
        uncommitted transaction data setup over the spec's database connection.
      MSG
    end

    DatabaseCleaner.clean_with(:deletion)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :deletion
  end

  config.before(:each, type: :request) do
    host!('localhost:8080')
  end

  config.after(:each, type: :request) do
    Warden.test_reset!
  end

  config.before(:each, type: :feature) do
    # :rack_test driver's Rack app under test shares database connection
    # with the specs, so continue to use transaction strategy for speed.
    driver_shares_db_connection_with_specs = Capybara.current_driver == :rack_test
    DatabaseCleaner.strategy = :deletion
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end

  # Seachkick testing config
  config.around(:each, search: true) do |example|
    Searchkick.callbacks(true) do
      example.run
    end
  end

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Add bullet wrapper to catch and log N+1 queries
  if Bullet.enable?
    config.before(:each) { Bullet.start_request }
    config.after(:each)  { Bullet.end_request }
  end

  # Settings for testing mailers
  config.before(:each, type: :mailer) do
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  config.after(:each, type: :mailer) do
    ActionMailer::Base.deliveries.clear
  end

  # randomize the order rspec uses when running
  config.order = :random
  Kernel.srand config.seed
end

# Config settings Shoulda Matchers gem
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec

    # Choose one or more libraries:
    with.library :active_record
    with.library :active_model
    with.library :action_controller
  end
end
