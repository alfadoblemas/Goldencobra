# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Dummy::Application.initialize!
Time::DATE_FORMATS[:date] = "%Y-&d-%m"